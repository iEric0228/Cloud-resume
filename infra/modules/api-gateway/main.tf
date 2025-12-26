#HTTP API - the main gateway
#Lambda Integration - connects API to your function
#Route - defines the endpoint (GET /count)
#Stage - deployment environment (prod)
#Lambda Permission - allows API Gateway to invoke Lambda

resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "visitor-counter-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_origins
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["content-type"]
  }

}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.visitor_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_invoke_arn
}

resource "aws_apigatewayv2_route" "get_count" {
  api_id = aws_apigatewayv2_api.visitor_api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}