output "rest_api_id" {
  description = "ID da API REST."
  value       = aws_api_gateway_rest_api.this.id
}

output "stage_name" {
  description = "Nome do stage."
  value       = aws_api_gateway_stage.this.stage_name
}

output "invoke_url" {
  description = "URL de invocacao do stage (formato AWS real)."
  value       = aws_api_gateway_stage.this.invoke_url
}

output "execution_arn" {
  description = "execution_arn da API (usado em permissoes)."
  value       = aws_api_gateway_rest_api.this.execution_arn
}
