output "function_name" {
  description = "Nome da funcao Lambda."
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN da funcao Lambda."
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "ARN de invocacao (usado pela API Gateway)."
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "ARN do role de execucao."
  value       = aws_iam_role.exec.arn
}
