variable "aws_region" {
  description = "AWS region for the state bucket (keep consistent with environments)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix — must match value used in environment backends"
  type        = string
  default     = "cloud-resume"
}
