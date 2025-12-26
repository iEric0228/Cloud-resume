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

resource "aws_s3_bucket" "cloud_resume_bucket" {
  bucket        = "cloud-resume-${var.environment}-${random_string.bucket_suffix.result}"
  force_destroy = var.force_destroy

  tags = {
    Name        = "CloudResumeBucket-${var.environment}"
    Environment = var.environment
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_website_configuration" "cloud_resume_website" {
  bucket = aws_s3_bucket.cloud_resume_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "cloud_resume_block_public" {
  bucket = aws_s3_bucket.cloud_resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "cloud_resume_versioning" {
  bucket = aws_s3_bucket.cloud_resume_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "cloud_resume_policy" {
  bucket     = aws_s3_bucket.cloud_resume_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.cloud_resume_block_public]

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
