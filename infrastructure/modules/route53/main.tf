# ============================================================
# Route53 Module
# - Creates DNS CNAME records to validate the ACM certificate
# - Runs aws_acm_certificate_validation (waits for DNS propagation)
# - Creates A alias records: www + root → CloudFront
#
# The hosted zone is created by the calling environment and
# passed in via var.zone_id.
# ============================================================

# ── Certificate Validation DNS Records ───────────────────────────────────────
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in var.certificate_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id         = var.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

# ── Wait for Certificate Validation ──────────────────────────────────────────
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = var.certificate_arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# ── www Alias → CloudFront ────────────────────────────────────────────────────
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront global hosted zone ID (constant)
    evaluate_target_health = false
  }
}

# ── Root Apex Alias → CloudFront ──────────────────────────────────────────────
resource "aws_route53_record" "root" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
