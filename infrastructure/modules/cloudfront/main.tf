# ============================================================
# CloudFront Distribution Module
# - Serves static website from S3 via Origin Access Control
# - Supports custom domain with ACM certificate
# - Enforces HTTPS, enables compression
# - PriceClass_100 (US/EU/APAC) for cost control
# ============================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

resource "random_string" "oac_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ── Origin Access Control ─────────────────────────────────────────────────────
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.project_name}-${var.environment}-oac-${random_string.oac_suffix.result}"
  description                       = "OAC for S3 bucket — ${var.environment}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ── CloudFront Distribution ───────────────────────────────────────────────────
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # US, Canada, Europe — cost-optimised

  # Custom domain aliases (only set when a validated cert is provided)
  aliases = var.certificate_arn != null ? [var.domain_name, "www.${var.domain_name}"] : []

  # ── Origin: S3 bucket via OAC ──────────────────────────────────────────────
  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = "s3-website-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # ── Cache Behaviour ────────────────────────────────────────────────────────
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-website-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 3600   # 1 hour
    max_ttl     = 86400  # 24 hours
  }

  # ── SPA Error Handling ─────────────────────────────────────────────────────
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # ── TLS / Viewer Certificate ───────────────────────────────────────────────
  viewer_certificate {
    # Use ACM cert when provided, otherwise fall back to CloudFront default
    cloudfront_default_certificate = var.certificate_arn == null ? true : false
    acm_certificate_arn            = var.certificate_arn
    ssl_support_method             = var.certificate_arn != null ? "sni-only" : null
    minimum_protocol_version       = var.certificate_arn != null ? "TLSv1.2_2021" : null
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudfront"
    Environment = var.environment
  }
}

# ── S3 Bucket Policy (allow CloudFront OAC only) ─────────────────────────────
resource "aws_s3_bucket_policy" "oac_policy" {
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}
