output "website_url" {
  description = "CloudFront distribution URL"
  value       = module.cloudfront.distribution_domain_name
}

output "api_url" {
  description = "API Gateway URL for visitor counter"
  value       = module.api_gateway.api_url
}

# ./infra/modules/cloudfront/outputs.tf
output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.this.id
}