output "api_url" {
  description = "The API Gateway invoke URL"
  value       = aws_apigatewayv2_stage.prod.invoke_url 
}

output "api_id" {
  description = "The API Gateway ID"
  value       = aws_apigatewayv2_api.visitor_api.id  
}

output "api_endpoint" {
  description = "The endpoint of the API Gateway"
  value       = aws_apigatewayv2_api.visitor_api.api_endpoint
}