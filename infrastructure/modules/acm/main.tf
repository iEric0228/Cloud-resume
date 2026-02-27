# ============================================================
# ACM Certificate Module
# Must be deployed in us-east-1 for CloudFront compatibility.
# Creates a DNS-validated wildcard certificate for the domain.
# ============================================================

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cert"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
