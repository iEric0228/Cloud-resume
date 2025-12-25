resource "aws_dynamodb_table" "visitor_count" {
    name        = "visitor-count-${var.environment}"
    hash_key    = "id"
    billing_mode = "PAY_PER_REQUEST"

    attribute {
        name = "id"
        type = "S"  # S = String
    }

    tags = {
    Name        = "visitor-count-${var.environment}"
    Environment = var.environment
}
}
resource "aws_dynamodb_table_item" "init_count" {
    table_name = aws_dynamodb_table.visitor_count.name
    hash_key   = "id"
    item       = jsonencode({
        id    = {
          S = "visitor_count"
        }
        count = {
          "N": "0"
        } 
    })
     lifecycle {
        ignore_changes = [item]  # Don't reset counter on updates
}
}