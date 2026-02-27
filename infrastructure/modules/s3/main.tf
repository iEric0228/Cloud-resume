# ============================================================
# S3 Static Website Module
# Security: Fully private bucket — access granted only via
# CloudFront OAC. No public bucket policy or ACL.
# ============================================================

terraform {
  required_version = ">= 1.0"
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

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# ── S3 Bucket ─────────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "this" {
  bucket        = "${var.project_name}-${var.environment}-${random_string.bucket_suffix.result}"
  force_destroy = var.force_destroy

  tags = {
    Name        = "${var.project_name}-${var.environment}-website"
    Environment = var.environment
  }
}

# ── Block ALL public access (CloudFront OAC handles delivery) ─────────────────
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── Server-side encryption ────────────────────────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ── Versioning ────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.environment == "prod" ? "Enabled" : "Suspended"
  }
}

# ── CORS ──────────────────────────────────────────────────────────────────────
resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://${var.domain_name}", "https://www.${var.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
