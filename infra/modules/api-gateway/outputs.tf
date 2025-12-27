output "api_url" {
  description = "The API Gateway invoke URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/count"
}

output "api_id" {
  description = "The API Gateway ID"
  value       = aws_api_gateway_rest_api.visitor_api.id
}

output "api_endpoint" {
  description = "The base endpoint of the API Gateway"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "stage_name" {
  description = "The API Gateway stage name"
  value       = aws_api_gateway_stage.prod.stage_name
}