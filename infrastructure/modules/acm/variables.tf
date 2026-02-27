variable "domain_name" {
  description = "Root domain name (e.g. ericchiu.page)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev/prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "cloud-resume"
}
