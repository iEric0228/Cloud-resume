output "distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation)"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "CloudFront domain name (e.g. d1234.cloudfront.net)"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "website_url" {
  description = "Primary website URL"
  value       = var.domain_name != null ? "https://www.${var.domain_name}" : "https://${aws_cloudfront_distribution.this.domain_name}"
}
