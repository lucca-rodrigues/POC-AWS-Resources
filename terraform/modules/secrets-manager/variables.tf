variable "name" {
  description = "Nome do segredo no Secrets Manager (ex.: core-bancario/cliente)."
  type        = string
}

variable "description" {
  description = "Descricao do segredo."
  type        = string
  default     = ""
}

variable "secret_string" {
  description = "Conteudo do segredo (JSON com chaves de configuracao da aplicacao)."
  type        = string
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Janela de recuperacao antes da exclusao definitiva. 0 em dev permite destruir/recriar o segredo imediatamente."
  type        = number
  default     = 0
}
