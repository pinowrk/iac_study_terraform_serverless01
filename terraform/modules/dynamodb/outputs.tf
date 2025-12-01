output "dynamodb_table_name" {
  description = "DynamoDBの名前"
  value       = aws_dynamodb_table.todos.name
}

output "dynamodb_table_arn" {
  description = "DynamoDBのARN"
  value       = aws_dynamodb_table.todos.arn
}
