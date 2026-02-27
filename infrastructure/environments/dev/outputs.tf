output "website_url" {
  description = "Primary website URL (custom domain when configured)"
  value       = module.cloudfront.website_url
}

output "cloudfront_domain" {
  description = "Raw CloudFront domain (useful for DNS debugging)"
  value       = module.cloudfront.distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation"
  value       = module.cloudfront.distribution_id
}

output "s3_bucket_name" {
  description = "S3 bucket name for website file deployment"
  value       = module.s3.bucket_name
}

output "api_url" {
  description = "API Gateway URL for the visitor counter"
  value       = module.api_gateway.api_url
}

output "lambda_function_name" {
  description = "Lambda function name for debugging"
  value       = module.lambda.function_name
}
