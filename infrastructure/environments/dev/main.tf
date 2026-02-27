# ============================================================
# Environment: dev
# Domain: www.ericchiu.page
#
# Dependency chain (no circular deps):
#   module.s3       → no deps
#   module.dynamodb → no deps
#   module.acm      → no deps (creates cert, outputs validation options)
#   module.lambda   → dynamodb
#   module.api_gateway → lambda
#   module.route53  → acm + cloudfront (validates cert, creates alias records)
#   module.cloudfront → s3 + route53 (uses validated cert ARN)
# ============================================================

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# ── Data layer ────────────────────────────────────────────────────────────────
module "dynamodb" {
  source      = "../../modules/dynamodb"
  environment = var.environment
}

# ── Static hosting bucket ─────────────────────────────────────────────────────
module "s3" {
  source        = "../../modules/s3"
  environment   = var.environment
  project_name  = var.project_name
  domain_name   = var.domain_name
  force_destroy = true
}

# ── ACM Certificate (us-east-1 required for CloudFront) ──────────────────────
module "acm" {
  source       = "../../modules/acm"
  domain_name  = var.domain_name
  environment  = var.environment
  project_name = var.project_name
}

# ── Route53: validate cert + create alias records ─────────────────────────────
# NOTE: Depends on both module.acm AND module.cloudfront.
#       Terraform resolves the graph correctly:
#         acm → (validation options) → route53 → (validated cert ARN) → cloudfront
#         cloudfront → (domain name) → route53 (alias records)
#       No circular dep because route53 and cloudfront can start provisioning
#       independently; route53 just waits for validation before outputting cert ARN.
module "route53" {
  source                                = "../../modules/route53"
  domain_name                           = var.domain_name
  cloudfront_domain_name                = module.cloudfront.distribution_domain_name
  certificate_arn                       = module.acm.certificate_arn
  certificate_domain_validation_options = module.acm.certificate_domain_validation_options
}

# ── Lambda ────────────────────────────────────────────────────────────────────
module "lambda" {
  source              = "../../modules/lambda"
  environment         = var.environment
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
}

# ── API Gateway ───────────────────────────────────────────────────────────────
module "api_gateway" {
  source               = "../../modules/api-gateway"
  environment          = var.environment
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.function_invoke_arn
  cors_origins         = ["https://${var.domain_name}", "https://www.${var.domain_name}"]
}

# ── CloudFront ────────────────────────────────────────────────────────────────
module "cloudfront" {
  source             = "../../modules/cloudfront"
  environment        = var.environment
  project_name       = var.project_name
  bucket_domain_name = module.s3.bucket_regional_domain_name
  bucket_arn         = module.s3.bucket_arn
  bucket_id          = module.s3.bucket_id
  domain_name        = var.domain_name
  certificate_arn    = module.route53.validated_certificate_arn
}
