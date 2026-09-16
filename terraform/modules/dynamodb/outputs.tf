output "table_name" {
  description = "Nome da tabela (usado pela aplicacao e IAM policy)."
  value       = aws_dynamodb_table.this.name
}

output "arn" {
  description = "ARN da tabela (usado em policies IAM da Lambda)."
  value       = aws_dynamodb_table.this.arn
}
