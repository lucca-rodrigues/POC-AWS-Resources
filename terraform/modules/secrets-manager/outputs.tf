output "arn" {
  description = "ARN do segredo (usado em policies IAM)."
  value       = aws_secretsmanager_secret.this.arn
}

output "name" {
  description = "Nome do segredo (usado pela aplicacao em SecretsManager__SecretId)."
  value       = aws_secretsmanager_secret.this.name
}
