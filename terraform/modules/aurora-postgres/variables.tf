variable "cluster_identifier" {
  description = "Identificador do cluster Aurora PostgreSQL."
  type        = string
}

variable "database_name" {
  description = "Nome do banco de dados inicial criado no cluster."
  type        = string
}

variable "master_username" {
  description = "Usuario master do cluster."
  type        = string
}

variable "master_password" {
  description = "Senha do usuario master. Usada apenas quando manage_master_user_password = false."
  type        = string
  sensitive   = true
  default     = null
}

variable "engine_version" {
  description = "Versao do engine Aurora PostgreSQL."
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Classe das instancias do cluster (ignorada pelo ministack, exigida pela API RDS)."
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "Quantidade de instancias no cluster (1 writer; >1 adiciona readers)."
  type        = number
  default     = 1
}

variable "apply_immediately" {
  description = "Aplica alteracoes imediatamente em vez de aguardar a janela de manutencao."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Nao cria snapshot final ao destruir o cluster. Desligue apenas em ambiente descartavel."
  type        = bool
  default     = false
}

variable "manage_master_user_password" {
  description = "Delega a senha master ao Secrets Manager, com rotacao gerida pela AWS. Evita que a senha transite por tfvars e fique registrada no state."
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Criptografia em repouso do cluster."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN da chave KMS para a criptografia em repouso. Nulo usa a chave gerenciada pela AWS."
  type        = string
  default     = null
}

variable "db_subnet_group_name" {
  description = "Subnet group do cluster. Nulo faz o cluster nascer na VPC default da conta."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "Security groups do cluster. Vazio faz o cluster usar o SG default da VPC."
  type        = list(string)
  default     = []
}

variable "backup_retention_period" {
  description = "Dias de retencao de backup automatico (minimo 1 no Aurora)."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "backup_retention_period deve estar entre 1 e 35."
  }
}

variable "preferred_backup_window" {
  description = "Janela UTC do backup automatico, no formato hh24:mi-hh24:mi."
  type        = string
  default     = "03:00-04:00"
}

variable "deletion_protection" {
  description = "Impede destruicao acidental do cluster. Desligue apenas em ambiente descartavel."
  type        = bool
  default     = true
}
