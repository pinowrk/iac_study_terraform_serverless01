output "function_name" {
  description = "Lambda関数名"
  value       = aws_lambda_function.health_check.function_name
}

output "function_arn" {
  description = "Lambda ARN"
  value       = aws_lambda_function.health_check.arn
}

output "invoke_arn" {
  description = "Lambda Invoke ARN"
  value       = aws_lambda_function.health_check.invoke_arn
}

output "function_version" {
  description = "Lambd バージョン"
  value       = aws_lambda_function.health_check.version
}
