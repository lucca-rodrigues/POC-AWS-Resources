output "table_name" {
  description = "Nome da tabela (usado pela aplicacao em configuracao/IAM policy)."
  value       = aws_dynamodb_table.this.name
}

output "arn" {
  description = "ARN da tabela (usado em policies IAM do consumer Lambda)."
  value       = aws_dynamodb_table.this.arn
}

output "gsi_status_inspecao_name" {
  description = "Nome do GSI por status_inspecao, para queries de listagem operacional."
  value       = "gsi_status_inspecao"
}
