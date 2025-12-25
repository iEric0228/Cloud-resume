variable "environment" {
    description = "The environment for the resources"
    type        = string
}


variable "delete_protection" {
    description = "Enable delete protection for the DynamoDB table"
    type        = bool
    default     = true
}