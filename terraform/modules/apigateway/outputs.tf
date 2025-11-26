output "rest_api_id" {
  description = "REST API ID"
  value       = aws_api_gateway_rest_api.main.id
}

output "execution_arn" {
  description = "API Gateway Execution ARN"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "invoke_url" {
  description = "API Gateway Invoke URL"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "root_resource_id" {
  description = "Root Resource ID"
  value       = aws_api_gateway_rest_api.main.root_resource_id
}
