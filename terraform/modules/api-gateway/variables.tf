variable "api_name" {
  description = "Nome da API REST no API Gateway."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "invoke_arn da Lambda (integracao AWS_PROXY)."
  type        = string
}

variable "lambda_function_name" {
  description = "Nome da funcao Lambda (para a lambda_permission)."
  type        = string
}

variable "stage_name" {
  description = "Nome do stage de deploy."
  type        = string
  default     = "dev"
}

variable "authorization" {
  description = "Tipo de autorizacao dos methods do API Gateway. NONE deixa a API aberta e so deve ser usado em ambiente local."
  type        = string
  default     = "NONE"

  validation {
    condition     = contains(["NONE", "AWS_IAM", "CUSTOM", "COGNITO_USER_POOLS"], var.authorization)
    error_message = "authorization deve ser NONE, AWS_IAM, CUSTOM ou COGNITO_USER_POOLS."
  }
}

variable "authorizer_id" {
  description = "Id do authorizer, obrigatorio quando authorization e CUSTOM ou COGNITO_USER_POOLS."
  type        = string
  default     = null

  validation {
    condition     = !contains(["CUSTOM", "COGNITO_USER_POOLS"], var.authorization) || var.authorizer_id != null
    error_message = "authorizer_id e obrigatorio quando authorization e CUSTOM ou COGNITO_USER_POOLS."
  }
}
