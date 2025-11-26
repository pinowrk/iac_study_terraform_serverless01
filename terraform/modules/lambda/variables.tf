variable "project" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
}

variable "lambda_zip_path" {
  description = "Lambdaデプロイパッケージ（zipファイル）のパス"
  type        = string
}

variable "lambda_role_arn" {
  description = "Lambda実行ロールのARN"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDBテーブル名"
  type        = string
}

# variable "api_gateway_execution_arn" {
#   description = "API GatewayのExecution ARN"
#   type        = string
# }
