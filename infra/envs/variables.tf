variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloud-resume"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for hosting static website"
  type        = string
}
