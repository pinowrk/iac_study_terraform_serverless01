variable "project" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "DynamoDBのARN"
  type        = string
}
