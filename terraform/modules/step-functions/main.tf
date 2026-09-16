# Módulo Step Functions: cria a máquina de estados (ASL) com a role de execucao.

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.state_machine_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_sfn_state_machine" "this" {
  name       = var.state_machine_name
  role_arn   = aws_iam_role.execution.arn
  definition = var.definition
}
