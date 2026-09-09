variable "repository_name" {
  description = "Nome do repositorio ECR."
  type        = string
}

variable "image_tag_mutability" {
  description = "Mutabilidade das tags: MUTABLE (permite sobrescrever) ou IMMUTABLE."
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability deve ser MUTABLE ou IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Executa scan de vulnerabilidades ao dar push da imagem."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Permite destruir o repositorio mesmo com imagens dentro (util em dev)."
  type        = bool
  default     = true
}
