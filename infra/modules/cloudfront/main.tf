resource "aws_cloudfront_distribution" "this" {
    enabled            = true
    
    //Tells CloudFront where content lives (S3)
    origin {
        domain_name = var.bucket_domain_name
        origin_id   = "s3-origin"
    }
    //Controls caching + HTTPS
    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods  = ["GET", "HEAD"]
        target_origin_id = "s3-origin"

        viewer_protocol_policy = "redirect-to-https"
    }
    //Default HTTPS cert
    viewer_certificate {
        cloudfront_default_certificate = true 
    }

    //Geographic restrictions (none by default)
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
}