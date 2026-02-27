# ============================================================
# Route53 Module
# - Looks up the existing hosted zone for the domain
# - Creates DNS CNAME records to validate the ACM certificate
# - Runs aws_acm_certificate_validation (waits for DNS propagation)
# - Creates A alias records: www + root → CloudFront
#
# PREREQUISITE: The hosted zone for var.domain_name must already
# exist in Route53 (i.e. the domain must be registered or
# delegated to Route53 name servers).
# ============================================================

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# ── Certificate Validation DNS Records ───────────────────────────────────────
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in var.certificate_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.main.zone_id
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
  zone_id = data.aws_route53_zone.main.zone_id
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
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
