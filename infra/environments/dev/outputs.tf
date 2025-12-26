output "website_url" {
  description = "CloudFront distribution URL"
  value       = module.cloudfront.distribution_domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for website"
  value       = module.s3.bucket_name
}

output "api_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.api_url
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}