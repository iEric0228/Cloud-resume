variable "environment" {
  description = "The environment for the deployment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "cloud-resume"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "cloud-resume-dev-website"
}
