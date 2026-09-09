variable "function_name" {
  description = "Nome da funcao Lambda."
  type        = string
}

variable "image_uri" {
  description = "URI da imagem de container no ECR (inclui a tag)."
  type        = string
}

variable "timeout" {
  description = "Timeout da funcao em segundos."
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memoria alocada para a funcao (MB)."
  type        = number
  default     = 512
}

variable "architectures" {
  description = "Arquiteturas suportadas pela imagem."
  type        = list(string)
  default     = ["x86_64"]
}

variable "environment_variables" {
  description = "Variaveis de ambiente injetadas na funcao."
  type        = map(string)
  default     = {}
}

variable "secret_arns" {
  description = "ARNs de segredos do Secrets Manager que a funcao pode ler (secretsmanager:GetSecretValue)."
  type        = list(string)
  default     = []
}
