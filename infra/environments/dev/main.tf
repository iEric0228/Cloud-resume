terraform {
  required_version = ">= 1.0"
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
      Project     = "cloud-resume"
      ManagedBy   = "terraform"
    }
  }
}

# DynamoDB table for visitor counter
module "dynamodb" {
  source      = "../../modules/dynamodb"
  environment = var.environment
}

# S3 bucket for static website hosting
module "s3" {
  source      = "../../modules/s3"
  environment = var.environment
  # Note: CloudFront ARN will be added after CloudFront is created
}

# Lambda function for visitor counter
module "lambda" {
  source              = "../../modules/lambda"
  environment         = var.environment
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
}

# API Gateway for Lambda access
module "api_gateway" {
  source               = "../../modules/api-gateway"
  environment          = var.environment
  lambda_function_name = module.lambda.function_name
  lambda_invoke_arn    = module.lambda.function_invoke_arn
  cors_origins         = ["*"] 
}

# CloudFront distribution for website
module "cloudfront" {
  source             = "../../modules/cloudfront"
  bucket_domain_name = module.s3.bucket_regional_domain_name
  bucket_arn         = module.s3.bucket_arn
  environment        = var.environment
}