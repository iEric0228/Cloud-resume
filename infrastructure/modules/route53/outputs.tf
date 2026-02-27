output "validated_certificate_arn" {
  description = "ARN of the fully validated ACM certificate (safe to pass to CloudFront)"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "www_record_fqdn" {
  description = "FQDN of the www Route53 record"
  value       = aws_route53_record.www.fqdn
}

output "root_record_fqdn" {
  description = "FQDN of the root Route53 record"
  value       = aws_route53_record.root.fqdn
}

output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}
