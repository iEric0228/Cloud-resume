# ============================================================
# Environment: dev
#
# Set enable_custom_domain = true to use a custom domain
# (requires an existing Route53 hosted zone for domain_name).
# When false, the site is served from the CloudFront default domain.
#
# Dependency chain:
#   module.s3          → no deps
#   module.dynamodb    → no deps
#   module.lambda      → dynamodb
#   module.api_gateway → lambda
#   module.cloudfront  → s3 (+ route53 when custom domain enabled)
#   module.acm         → (only when custom domain enabled)
#   module.route53     → acm + cloudfront (only when custom domain enabled)
# ============================================================

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state — values supplied via:
  #   terraform init -backend-config=backend.hcl          (local)
  #   -backend-config flags in CI/CD pipeline             (GitHub Actions)
  # Run infrastructure/bootstrap first to create the bucket + table.
  backend "s3" {}
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

# ── ACM Certificate (only when custom domain is enabled) ─────────────────────
# Requires an existing Route53 hosted zone for var.domain_name.
module "acm" {
  count        = var.enable_custom_domain ? 1 : 0
  source       = "../../modules/acm"
  domain_name  = var.domain_name
  environment  = var.environment
  project_name = var.project_name
}

# ── Route53: validate cert + create alias records (only with custom domain) ──
module "route53" {
  count                                 = var.enable_custom_domain ? 1 : 0
  source                                = "../../modules/route53"
  domain_name                           = var.domain_name
  cloudfront_domain_name                = module.cloudfront.distribution_domain_name
  certificate_arn                       = module.acm[0].certificate_arn
  certificate_domain_validation_options = module.acm[0].certificate_domain_validation_options
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
  cors_origins = var.enable_custom_domain ? [
    "https://${var.domain_name}",
    "https://www.${var.domain_name}"
  ] : ["*"]
}

# ── CloudFront ────────────────────────────────────────────────────────────────
# When enable_custom_domain = false, uses CloudFront default domain (d1234.cloudfront.net)
module "cloudfront" {
  source             = "../../modules/cloudfront"
  environment        = var.environment
  project_name       = var.project_name
  bucket_domain_name = module.s3.bucket_regional_domain_name
  bucket_arn         = module.s3.bucket_arn
  bucket_id          = module.s3.bucket_id
  domain_name        = var.enable_custom_domain ? var.domain_name : null
  certificate_arn    = var.enable_custom_domain ? module.route53[0].validated_certificate_arn : null
}
