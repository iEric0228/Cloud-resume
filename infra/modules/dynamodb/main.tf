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

resource "aws_dynamodb_table_item" "init_count" {
    table_name = aws_dynamodb_table.visitor_count.name
    hash_key   = "id"
    item       = jsonencode({
        id = {
          S = "visitor_count"
        }
        count = {
          N = "0"
        }
    })
    lifecycle {
        ignore_changes = [item]
    }
}