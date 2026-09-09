variable "table_name" {
  description = "Nome da tabela DynamoDB (ex.: corebancario-poison-messages-dev)."
  type        = string
}

variable "billing_mode" {
  description = "Modo de cobranca da tabela. PAY_PER_REQUEST evita provisionar capacidade em dev/homolog."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "ttl_habilitado" {
  description = "Habilita expiracao automatica de itens via o atributo `ttl` (epoch seconds)."
  type        = bool
  default     = true
}

# Default false pensado para dev-local (ministack): sem custo, sem dado real a recuperar.
# Em homolog/prod, onde a tabela guarda poison message de verdade (evidência operacional),
# instanciar o modulo com este valor true — não confiar no default aqui.
variable "point_in_time_recovery_habilitado" {
  description = "Habilita PITR. OBRIGATORIO true em homolog/prod (dado real); false só é aceitável em dev-local."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags adicionais aplicadas a tabela."
  type        = map(string)
  default     = {}
}
