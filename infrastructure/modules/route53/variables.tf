variable "zone_id" {
  description = "Route53 hosted zone ID (created by the calling environment)"
  type        = string
}

variable "domain_name" {
  description = "Root domain name (e.g. ericchiu.page)"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (e.g. d1234.cloudfront.net)"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN (from acm module)"
  type        = string
}

variable "certificate_domain_validation_options" {
  description = "Domain validation options from aws_acm_certificate"
  type = set(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}
