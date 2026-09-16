# Módulo DynamoDB

Tabela DynamoDB para registro de steps de processos (jornadas, workflows).

## Uso

```hcl
module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name = "jornada_steps"
}
```

## Recursos

- `aws_dynamodb_table.this` — tabela com chave de partição + ordenação

## Outputs

- `table_name` — nome da tabela
- `arn` — ARN da tabela (IAM policy)

> Para registro de steps de workflows (Step Functions), a chave é
> `jornada_id` (partição) + `step` (ordenação) — cada step vira um item com status.
