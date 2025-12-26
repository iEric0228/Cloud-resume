terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# HTTP API - the main gateway
resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "visitor-counter-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = length(var.cors_origins) > 0 ? var.cors_origins : ["*"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key"]
  }

  tags = {
    Name        = "VisitorCounterAPI-${var.environment}"
    Environment = var.environment
  }
}

# Lambda Integration - connects API to your function
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.visitor_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_invoke_arn
  integration_method = "POST"
}

# Route - defines the endpoint (GET /count)
resource "aws_apigatewayv2_route" "get_count" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Stage - deployment environment (prod)
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "prod"
  auto_deploy = true

  tags = {
    Name        = "VisitorCounterAPI-${var.environment}-prod"
    Environment = var.environment
  }
}

# Lambda Permission - allows API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}
