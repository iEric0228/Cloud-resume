output "bucket_name" {
    description = "The name of the S3 bucket"
    value       = aws_s3_bucket.cloud_resume_bucket.id
}

output "bucket_domain_name" {
    description = "The domain name of the S3 bucket"
    value       = aws_s3_bucket.cloud_resume_bucket.bucket_domain_name
}

output "bucket_arn" {
    description = "The ARN of the S3 bucket"
    value       = aws_s3_bucket.cloud_resume_bucket.arn
}

output "bucket_regional_domain_name" {
    description = "The regional domain name of the S3 bucket"
    value       = aws_s3_bucket.cloud_resume_bucket.bucket_regional_domain_name
}

output "website_endpoint" {
    description = "S3 website endpoint"
    value       = aws_s3_bucket_website_configuration.cloud_resume_website.website_endpoint
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "cloud-resume-${var.environment}-oac-${random_string.suffix.result}"
  description                       = "OAC for S3 bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_dynamodb_table" "visitor_count" {
  name           = "visitor-count-${var.environment}-${random_string.table_suffix.result}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "VisitorCountTable-${var.environment}"
    Environment = var.environment
  }
}

resource "random_string" "table_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_iam_role" "lambda_role" {
  name = "visitor-counter-lambda-role-${var.environment}-${random_string.lambda_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "random_string" "lambda_suffix" {
  length  = 6
  special = false
  upper   = false
}