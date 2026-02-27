variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "project_name" {
  description = "Project name prefix for bucket naming"
  type        = string
  default     = "cloud-resume"
}

variable "domain_name" {
  description = "Custom domain for CORS allow-list (e.g. ericchiu.page)"
  type        = string
  default     = "ericchiu.page"
}

variable "force_destroy" {
  description = "Allow Terraform to destroy bucket with objects (use false in prod)"
  type        = bool
  default     = true
}
