terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
# S3 bucket for website hosting
resource "aws_s3_bucket" "cloud_resume_bucket" {
  bucket = "cloud-resume-${var.environment}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "CloudResumeBucket-${var.environment}"
    Environment = var.environment
  }
}

# Random suffix for unique bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Separate website configuration
resource "aws_s3_bucket_website_configuration" "cloud_resume_website" {
  bucket = aws_s3_bucket.cloud_resume_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Public access configuration
resource "aws_s3_bucket_public_access_block" "cloud_resume_pab" {
  bucket = aws_s3_bucket.cloud_resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy for public read access
resource "aws_s3_bucket_policy" "cloud_resume_policy" {
  bucket = aws_s3_bucket.cloud_resume_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.cloud_resume_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.cloud_resume_bucket.arn}/*"
      }
    ]
  })
}