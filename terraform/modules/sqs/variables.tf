variable "queue_name" {
  description = "Nome da fila SQS."
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Tempo que a mensagem fica invisivel apos um receive (deve ser >= timeout da Lambda)."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Tempo de retencao da mensagem na fila."
  type        = number
  default     = 345600
}

variable "max_receive_count" {
  description = "Numero de recebimentos antes de enviar para a DLQ."
  type        = number
  default     = 3
}

variable "dlq_arn" {
  description = "ARN de uma DLQ existente. Quando null, o modulo cria a DLQ."
  type        = string
  default     = null
}

variable "dlq_message_retention_seconds" {
  description = "Tempo de retencao da mensagem na DLQ."
  type        = number
  default     = 1209600
}
