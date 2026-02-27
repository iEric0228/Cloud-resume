output "state_bucket_name" {
  description = "S3 bucket name — paste into each environment's backend.hcl"
  value       = aws_s3_bucket.tfstate.id
}

output "state_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.tfstate.arn
}

output "lock_table_name" {
  description = "DynamoDB table name — paste into each environment's backend.hcl"
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "backend_hcl_snippet" {
  description = "Ready-to-paste backend.hcl content for each environment"
  value       = <<-EOT
    bucket         = "${aws_s3_bucket.tfstate.id}"
    region         = "${var.aws_region}"
    encrypt        = true
    dynamodb_table = "${aws_dynamodb_table.tfstate_lock.name}"
  EOT
}
