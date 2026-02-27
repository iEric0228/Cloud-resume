variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "cloud-resume"
}

variable "aws_region" {
  description = "AWS region for deployment (ACM for CloudFront must be us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Root domain name for the website (e.g. ericchiu.page)"
  type        = string
  default     = "ericchiu.page"
}

variable "enable_custom_domain" {
  description = "Enable custom domain with ACM certificate and Route53 records. Requires an existing Route53 hosted zone for domain_name. When false, the site is served from the CloudFront default domain."
  type        = bool
  default     = false
}
