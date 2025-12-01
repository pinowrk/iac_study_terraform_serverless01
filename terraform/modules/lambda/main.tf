resource "aws_lambda_function" "health_check" {
  filename      = var.lambda_zip_path
  function_name = "${var.project}_${var.environment}_health_check"
  role          = var.lambda_role_arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 128

  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      ENVIRONMENT         = var.environment
    }
  }

  tags = {
    Name = "${var.project}_${var.environment}_health_check"
  }
}

# resource "aws_lambda_permission" "api_gateway" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.health_check.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${var.api_gateway_execution_arn}/*/*"
# }

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.health_check.function_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project}_${var.environment}_lambda_logs"
  }
}
