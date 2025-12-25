output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.visitor_counter.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.visitor_counter.function_name
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.visitor_counter.invoke_arn
}