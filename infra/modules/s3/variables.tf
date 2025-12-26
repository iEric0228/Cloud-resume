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
    default     = true  # ✅ Change to true for easier cleanup
}