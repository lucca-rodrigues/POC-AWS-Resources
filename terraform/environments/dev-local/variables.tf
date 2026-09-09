variable "app_secret_name" {
  description = "Nome do segredo da aplicacao no Secrets Manager."
  type        = string
  default     = "futurosign/app"
}

variable "api_gateway_name" {
  description = "Nome da API REST no API Gateway."
  type        = string
  default     = "futurosign-api"
}

variable "api_gateway_stage" {
  description = "Nome do stage do API Gateway."
  type        = string
  default     = "dev"
}

variable "stage" {
  description = "Stage da aplicacao (injetado como env var nas functions)."
  type        = string
  default     = "dev"
}
