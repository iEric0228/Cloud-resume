# ============================================================
# Bootstrap — Terraform Remote State Infrastructure
#
# Run this ONCE before any other terraform apply:
#   cd infrastructure/bootstrap
#   terraform init
#   terraform apply
#
# This uses local state intentionally (it creates the remote
# state backend itself). The resulting bucket/table are
# referenced by all other environment backends.
# ============================================================

terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Intentionally LOCAL state — this module bootstraps the remote backend
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
      Purpose   = "terraform-state"
    }
  }
}

# ── S3 State Bucket ───────────────────────────────────────────────────────────
resource "aws_s3_bucket" "tfstate" {
  bucket        = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
  force_destroy = false # Protect state — never auto-delete

  tags = {
    Name = "${var.project_name}-tfstate"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled" # Required — allows rollback to previous state files
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90 # Keep 90 days of state history
    }
  }
}

# ── DynamoDB Lock Table ───────────────────────────────────────────────────────
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = "${var.project_name}-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-tfstate-lock"
  }
}

data "aws_caller_identity" "current" {}
