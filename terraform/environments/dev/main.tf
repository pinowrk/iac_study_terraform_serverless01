provider "aws" {
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  project     = var.project
  environment = var.environment
}

module "iam" {
  source = "../../modules/iam"

  project            = var.project
  environment        = var.environment
  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
}

module "lambda" {
  source = "../../modules/lambda"

  project             = var.project
  environment         = var.environment
  lambda_zip_path     = "${path.module}/../../lambda_packages/health_check.zip"
  lambda_role_arn     = module.iam.lambda_role_arn
  dynamodb_table_name = module.dynamodb.dynamodb_table_name
}

module "apigateway" {
  source = "../../modules/apigateway"

  project           = var.project
  environment       = var.environment
  lambda_invoke_arn = module.lambda.invoke_arn
}

# Lambda Permission（循環依存回避のためここで定義）
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.apigateway.execution_arn}/*/*"

  depends_on = [
    module.lambda,
    module.apigateway
  ]
}
