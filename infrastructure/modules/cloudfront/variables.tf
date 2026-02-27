variable "bucket_domain_name" {
  description = "S3 bucket regional domain name for the CloudFront origin"
  type        = string
}

variable "bucket_arn" {
  description = "S3 bucket ARN (for OAC bucket policy)"
  type        = string
}

variable "bucket_id" {
  description = "S3 bucket ID / name (for attaching the bucket policy)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev/prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name prefix for resource naming"
  type        = string
  default     = "cloud-resume"
}

variable "domain_name" {
  description = "Custom domain (e.g. ericchiu.page). Required when certificate_arn is set."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "Validated ACM certificate ARN. When null, uses CloudFront default cert."
  type        = string
  default     = null
}
