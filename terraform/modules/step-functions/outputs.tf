output "state_machine_arn" {
  description = "ARN da maquina de estados."
  value       = aws_sfn_state_machine.this.arn
}

output "state_machine_name" {
  description = "Nome da maquina de estados."
  value       = aws_sfn_state_machine.this.name
}

output "role_arn" {
  description = "ARN da role de execucao."
  value       = aws_iam_role.execution.arn
}

output "role_name" {
  description = "Nome da role de execucao (usado em aws_iam_role_policy)."
  value       = aws_iam_role.execution.name
}
