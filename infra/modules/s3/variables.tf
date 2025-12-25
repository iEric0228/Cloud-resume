variable "bucket_name" {
    description = "The name of the S3 bucket"
    type       = string
    validation {
        condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
        error_message = "Bucket name must be between 3 and 63 characters."
    }
}

variable "environment" {
    description = "The deployment environment (e.g., dev, prod)"
    type        = string

    validation {
        condition     = contains(["dev", "prod"], var.environment)
        error_message = "Environment must be either 'dev' or 'prod'."
    }

}

variable "force_destroy" {
    description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
    type        = bool
    default     = false
}