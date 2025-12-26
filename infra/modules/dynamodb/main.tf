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
  name             = "${var.project_name}-visitor-count-${var.environment}"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "VisitorCountTable-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Initialize the counter
resource "aws_dynamodb_table_item" "visitor_count_init" {
  table_name = aws_dynamodb_table.visitor_count.name
  hash_key   = aws_dynamodb_table.visitor_count.hash_key

  item = <<ITEM
{
  "id": {"S": "visitor_count"},
  "count": {"N": "0"}
}
ITEM

  lifecycle {
    ignore_changes = [item]
  }
}