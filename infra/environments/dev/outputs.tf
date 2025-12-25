output "website_url" {
  description = "CloudFront distribution URL"
  value       = module.cloudfront.distribution_domain_name
}

output "api_url" {
  description = "API Gateway URL for visitor counter"
  value       = "${module.api_gateway.api_url}/count"
}
