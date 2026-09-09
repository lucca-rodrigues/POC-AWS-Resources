output "repository_url" {
  description = "URL do repositorio (usada no docker push/pull)."
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN do repositorio."
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Nome do repositorio."
  value       = aws_ecr_repository.this.name
}

output "registry_id" {
  description = "ID do registry (conta) onde o repositorio foi criado."
  value       = aws_ecr_repository.this.registry_id
}
