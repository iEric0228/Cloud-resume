variable "bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  type        = string
}

variable "bucket_arn" {
  description = "The ARN of the S3 bucket for OAC"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
  default     = "dev"
}