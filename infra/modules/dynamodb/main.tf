terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_dynamodb_table" "visitor_count" {
  name             = "cloud-resume-visitor-count-${var.environment}"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "CloudResumeVisitorCount-${var.environment}"
    Environment = var.environment
  }
}