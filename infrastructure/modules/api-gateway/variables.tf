variable "environment" {
  description = "The environment for the deployment"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The ARN for invoking the Lambda function"
  type        = string
}

variable "cors_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}