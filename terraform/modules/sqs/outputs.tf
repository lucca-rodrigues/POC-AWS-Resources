output "queue_url" {
  description = "URL da fila SQS (usada para enviar mensagens)."
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "ARN da fila SQS (usado no event source mapping)."
  value       = aws_sqs_queue.this.arn
}

output "dlq_arn" {
  description = "ARN da DLQ."
  value       = var.dlq_arn != null ? var.dlq_arn : aws_sqs_queue.dlq[0].arn
}
