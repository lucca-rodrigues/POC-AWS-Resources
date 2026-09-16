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

# --- Function integracao -----------------------------------------------------

variable "cluster_identifier" {
  description = "Identificador do cluster Aurora PostgreSQL."
  type        = string
  default     = "futurosign-integracao"
}

variable "db_name" {
  description = "Nome do banco criado no cluster."
  type        = string
  default     = "futurosign"
}

variable "db_host_override" {
  description = "Host real do container Postgres na rede docker (floci). Vazio usa o endpoint do cluster."
  type        = string
  default     = ""
}

variable "db_port_override" {
  description = "Porta real do container Postgres na rede docker (floci). Vazio usa a porta do cluster."
  type        = string
  default     = ""
}

variable "master_username" {
  description = "Usuario master do cluster."
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Senha do usuario master (dev)."
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "engine_version" {
  description = "Versao do Aurora PostgreSQL."
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Classe da instancia do cluster (ignorada pelo floci, exigida pela API)."
  type        = string
  default     = "db.t3.medium"
}

variable "sqs_queue_name" {
  description = "Nome da fila SQS de entrada da function integracao."
  type        = string
  default     = "futurosign-integracao"
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 de artefatos."
  type        = string
  default     = "futurosign-artefatos"
}

variable "kafka_bootstrap_servers" {
  description = "Brokers Kafka (MSK do floci — Redpanda na rede docker)."
  type        = string
  default     = "172.20.0.11:9092"
}

variable "kafka_topic" {
  description = "Topico Kafka de eventos de status."
  type        = string
  default     = "futurosign.integracao.status.tpc"
}

# --- Integracoes externas (credenciais mock em dev) --------------------------
variable "click_sign_base_url" {
  description = "URL base da Click Sign (valor mock em dev)."
  type        = string
  default     = "https://api.clicksign.com/api/v1"
}

variable "click_sign_access_token" {
  description = "Access token da Click Sign (mock em dev)."
  type        = string
  default     = "click-sign-token-dev"
  sensitive   = true
}

variable "zenvia_base_url" {
  description = "URL base da Zenvia (valor mock em dev)."
  type        = string
  default     = "https://api.zenvia.com/v2"
}

variable "zenvia_api_token" {
  description = "API token da Zenvia (mock em dev)."
  type        = string
  default     = "zenvia-token-dev"
  sensitive   = true
}
