resource "aws_s3_bucket" "cloud_resume_bucket" {
    bucket = var.bucket_name
    
    website {
        index_document = "index.html"
        error_document = "error.html"
    }
    
    tags = {
        Name        = var.bucket_name
        Environment = var.environment

    }
}

resource "aws_s3_bucket_website_configuration" "cloud_resume_bucket_website" {
    bucket = aws_s3_bucket.cloud_resume_bucket.id

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}

resource "aws_s3_bucket_public_access_block" "cloud_resume_bucket_public_access_block" {
    bucket = aws_s3_bucket.cloud_resume_bucket.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}
