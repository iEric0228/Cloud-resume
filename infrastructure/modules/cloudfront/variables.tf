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

variable "content_security_policy" {
  description = "Content-Security-Policy header value applied to all responses. Default allows Google Fonts and the regional API Gateway (visitor counter)."
  type        = string
  default     = "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data:; connect-src 'self' https://*.execute-api.us-east-1.amazonaws.com; object-src 'none'; base-uri 'self'; frame-ancestors 'none'; form-action 'self'; upgrade-insecure-requests"
}

variable "hsts_preload" {
  description = "Add the HSTS preload directive. Leave false unless you intend to submit the domain to the browser preload list (hard to reverse)."
  type        = bool
  default     = false
}
