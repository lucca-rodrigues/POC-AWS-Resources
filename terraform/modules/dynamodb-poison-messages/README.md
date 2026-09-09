# Módulo `dynamodb-poison-messages`

Provisiona a tabela DynamoDB de inspeção operacional de *poison messages* (CB-174),
complementar à Dead Letter Topic por domínio (CB-173). Toda mensagem do MSK que o
consumer não consegue processar é enviada à DLT **e** registrada aqui, com motivo
da falha, para permitir inspeção/reprocessamento manual pela operação sem precisar
ler offset de Kafka diretamente.

> Este módulo cobre só a infraestrutura (tabela + índice). O código que grava/lê o
> item — o consumer Lambda (CB-170) e o tratamento de DLT (CB-173) — está em
> branches próprias (`feature/cb-170-lydians-consumer`, `feature/cb-173-poison-dlt`),
> não faz parte deste módulo nem desta branch.

## Modelo de dados

| Atributo | Tipo | Papel |
|---|---|---|
| `dominio` | String | **PK** — `"desembolso"`, `"cliente"` (mesmo particionamento por domínio da DLT) |
| `message_id` | String | **SK** — `message_id` original do MSK |
| `topico_origem` | String | tópico Lydians de onde a mensagem veio |
| `tipo_mensagem` | String | tipo/schema esperado |
| `motivo_falha` | String | ex.: `SCHEMA_INVALIDO`, `PARSING_ERROR`, `CORRELACAO_AUSENTE` |
| `detalhe_erro` | String | mensagem de exceção resumida |
| `payload_bruto` | String (base64) | conteúdo cru da mensagem; se grande, referenciar S3 em vez de gravar direto |
| `correlation_id` | String | se extraível antes da falha |
| `recebido_em` | String (ISO 8601) | quando a mensagem chegou |
| `status_inspecao` | String | `PENDENTE` / `REPROCESSADA` / `DESCARTADA` |
| `ttl` | Number (epoch) | expiração automática (alinhar com a retenção de 180 dias usada em `requisicao_provider`) |

**GSI `gsi_status_inspecao`** (`status_inspecao` + `recebido_em`): lista todo item
`PENDENTE` de um domínio sem varrer a tabela inteira.

Estes atributos além de `dominio`/`message_id`/`status_inspecao`/`recebido_em` não
são declarados como `attribute` no Terraform — DynamoDB é schemaless fora da chave
primária e dos índices; a aplicação (Lambda consumer) é quem grava/lê o item completo.

## Uso

```hcl
# dev-local (ministack): default point_in_time_recovery_habilitado = false está OK aqui.
module "poison_messages" {
  source = "../../modules/dynamodb-poison-messages"

  table_name = "corebanking-desembolso-poison-messages-dev"
}
```

```hcl
# homolog/prod: PITR OBRIGATORIO — a tabela guarda evidência operacional real, o
# default do módulo (false) é pensado só para dev-local e não deve ser herdado aqui.
module "poison_messages" {
  source = "../../modules/dynamodb-poison-messages"

  table_name                        = "corebanking-desembolso-poison-messages-homolog"
  point_in_time_recovery_habilitado = true
}
```

## Inputs

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `table_name` | string | — | Nome da tabela. |
| `billing_mode` | string | `PAY_PER_REQUEST` | Evita provisionar capacidade em dev/homolog. |
| `ttl_habilitado` | bool | `true` | Habilita expiração automática via atributo `ttl`. |
| `point_in_time_recovery_habilitado` | bool | `false` | **Obrigatório `true` em homolog/prod** — o default é pensado só para dev-local. |
| `tags` | map(string) | `{}` | Tags adicionais. |

## Outputs

| Nome | Descrição |
|------|-----------|
| `table_name` | Nome da tabela (configuração/IAM policy da aplicação). |
| `arn` | ARN da tabela (policy IAM do consumer Lambda). |
| `gsi_status_inspecao_name` | Nome do GSI, para montar queries de listagem operacional. |
