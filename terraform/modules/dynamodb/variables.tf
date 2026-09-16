variable "table_name" {
  description = "Nome da tabela DynamoDB."
  type        = string
}

variable "billing_mode" {
  description = "Modo de cobranca (PAY_PER_REQUEST ou PROVISIONED)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Chave de particao."
  type        = string
  default     = "jornada_id"
}

variable "hash_key_type" {
  description = "Tipo da chave de particao (S, N ou B)."
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "Chave de ordenacao."
  type        = string
  default     = "step"
}

variable "range_key_type" {
  description = "Tipo da chave de ordenacao (S, N ou B)."
  type        = string
  default     = "S"
}
