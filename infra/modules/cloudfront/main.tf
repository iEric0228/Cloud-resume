resource "aws_cloudfront_distribution" "this" {
    enabled = true
    
    # Origin configuration
    origin {
        domain_name = var.bucket_domain_name
        origin_id   = "s3-origin"
        
        origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    }
    
    # Cache behavior  
    default_cache_behavior {
        allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        target_origin_id       = "s3-origin"
        viewer_protocol_policy = "redirect-to-https"
    
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }
    
    default_root_object = "index.html"
    
    # Viewer certificate
    viewer_certificate {
        cloudfront_default_certificate = true
    }
    
    # Restrictions
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    
    tags = {
        Environment = var.environment
        Name        = "cloud-resume-${var.environment}-cloudfront"
    }
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "cloud-resume-${var.environment}-oac-${random_string.suffix.result}"
  description                       = "OAC for S3 bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}