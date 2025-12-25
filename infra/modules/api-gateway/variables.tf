variable "environment" {
    description = "The environment for the Lambda function (e.g., dev, prod)"
    type        = string
}

variable "lambda_function_name" {
    description = "The name of the Lambda function to be used with the API Gateway"
    type        = string
}

variable "lambda_invoke_arn" {
    description = "The ARN for invoking the Lambda function"
    type        = string
}

variable "cors_origins" {
    description = "List of allowed CORS origins"
    type        = list(string)
    default     = []
}