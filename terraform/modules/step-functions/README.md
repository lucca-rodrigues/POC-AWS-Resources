# Módulo Step Functions

Máquina de estados (AWS Step Functions) com role de execução.

## Uso

```hcl
module "step_functions" {
  source = "../../modules/step-functions"

  state_machine_name = "futurosign-jornada"
  definition         = file("asl/jornada.json")
}
```

## Recursos

- `aws_sfn_state_machine.this` — máquina de estados (definição ASL)
- `aws_iam_role.execution` — role de execução (assume role states.amazonaws.com)

## Outputs

- `state_machine_arn` — ARN da máquina (para invocar)
- `state_machine_name` — nome
- `role_arn` — role de execução

> **Nota**: a role precisa de policies adicionais para invocar Lambdas
> (`lambda:InvokeFunction`) e gravar no DynamoDB (`dynamodb:PutItem`) — declaradas
> no ambiente (dev-local) conforme a jornada.
