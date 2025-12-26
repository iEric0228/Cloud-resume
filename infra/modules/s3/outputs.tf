output "bucket_name" {
    description = "The name of the S3 bucket"
    value       = aws_s3_bucket.cloud_resume_bucket.id
}

output "bucket_domain_name" {
    description = "The domain name of the S3 bucket"
    value       = aws_s3_bucket.cloud_resume_bucket.bucket_domain_name
}

output "bucket_arn" {
    description = "The ARN of the S3 bucket"
    value       = aws_s3_bucket.cloud_resume_bucket.arn
}

output "bucket_regional_domain_name" {
    description = "The AWS region where the S3 bucket is created"
    value       = aws_s3_bucket.cloud_resume_bucket._regional_domain_name
}

output "website_endpoint" {
  description = "S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.cloud_resume_website.website_endpoint
}