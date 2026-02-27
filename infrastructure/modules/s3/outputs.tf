output "bucket_id" {
  description = "S3 bucket name / ID"
  value       = aws_s3_bucket.this.id
}

output "bucket_name" {
  description = "S3 bucket name (alias for bucket_id)"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name for CloudFront origin"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
