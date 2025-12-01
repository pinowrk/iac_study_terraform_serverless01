output "lambda_role_arn" {
  description = "Lambda実行ロールのARN"
  value       = aws_iam_role.allow_lambda_role.arn
}

output "lambda_role_name" {
  description = "Lambda実行ロールの名前"
  value       = aws_iam_role.allow_lambda_role.name
}
