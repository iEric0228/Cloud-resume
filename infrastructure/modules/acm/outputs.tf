output "certificate_arn" {
  description = "ARN of the ACM certificate (may still be PENDING_VALIDATION)"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_validation_options" {
  description = "DNS records required to validate the certificate"
  value       = aws_acm_certificate.this.domain_validation_options
}
