output "cluster_id" {
  description = "Identificador do cluster criado."
  value       = aws_rds_cluster.corebanking.id
}

output "cluster_endpoint" {
  description = "Endpoint de escrita (writer) do cluster."
  value       = aws_rds_cluster.corebanking.endpoint
}

output "reader_endpoint" {
  description = "Endpoint de leitura (reader) do cluster."
  value       = aws_rds_cluster.corebanking.reader_endpoint
}

output "port" {
  description = "Porta do cluster."
  value       = aws_rds_cluster.corebanking.port
}

output "database_name" {
  description = "Nome do banco de dados inicial."
  value       = aws_rds_cluster.corebanking.database_name
}
