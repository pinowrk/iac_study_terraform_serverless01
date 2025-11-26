variable "project" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda Invoke ARN"
  type        = string
}
