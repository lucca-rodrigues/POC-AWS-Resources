variable "state_machine_name" {
  description = "Nome da maquina de estados."
  type        = string
}

variable "definition" {
  description = "Definicao ASL (Amazon States Language) da maquina de estados."
  type        = string
}
