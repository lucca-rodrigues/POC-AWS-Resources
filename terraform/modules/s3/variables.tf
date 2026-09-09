variable "bucket_name" {
  description = "Nome do bucket S3."
  type        = string
}

variable "force_destroy" {
  description = "Permite destruir o bucket mesmo com objetos dentro (util em dev)."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Habilita versionamento de objetos no bucket."
  type        = bool
  default     = false
}
