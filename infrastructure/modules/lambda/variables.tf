variable "environment" {
    description = "The environment for the Lambda function (e.g., dev, prod)"
    type       = string
}

variable "dynamodb_table_name" {
    description = "The name of the DynamoDB table"
    type       = string
}

variable "dynamodb_table_arn" {
    description = "The ARN of the DynamoDB table"
    type       = string
}