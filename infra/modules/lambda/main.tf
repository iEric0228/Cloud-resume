data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../backend/lambda"  # Your Python code location
  output_path = "${path.module}/lambda_function.zip"      # Where to create ZIP
}

resource "aws_iam_role" "lambda_role" {
  name = "visitor-counter-lambda-role-${var.environment}"

  #Trust policy - allow Lambda to assume this role 
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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "visitor-counter-dynamodb-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = var.dynamodb_table_arn # From DynamoDB module
      }
    ]
  })
}

resource "aws_lambda_function" "visitor_counter" {
  filename = data.archive_file.lambda_zip.output_path
  function_name = "visitor-counter-${var.environment}"
  role = aws_iam_role.lambda_role.arn
  handler = "handler.lambda_handler"
  runtime = "python3.11"

  environment {
    variable = {
      TABLE_NAME = var.dynamodb_table_name
  }
}
}

