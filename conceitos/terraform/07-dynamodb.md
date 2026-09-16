# DynamoDB — Banco NoSQL

## O que é
DynamoDB é o **banco NoSQL (chave-valor/documento)** da AWS — serverless, com
escala automática. Ideal para dados de **processos/operacionais** (steps de
workflows, sessões, eventos) em vez do banco principal de negócio.

## Para que serve
- **Registrar steps de workflows** (jornada, processo) — se der erro, sabe onde parou
- **Sessões/estado efêmero** — rápido e barato
- **Eventos/auditoria operacional**
- **Banco principal** (Aurora PG) fica para os dados de negócio (premissa da spec)

## Tabela de steps (padrão da POC)

```hcl
# terraform/modules/dynamodb/main.tf
resource "aws_dynamodb_table" "this" {
  name         = "jornada_steps"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "jornada_id"   # partição
  range_key    = "step"         # ordenação
}
```

Cada step da máquina vira um **item**:

```json
{
  "jornada_id": "jornada-001",
  "step": "criar-envelope",
  "status": "ok",
  "recebido_em": "2026-09-16T12:00:00Z"
}
```

## Gravar da Lambda (SDK)

```javascript
const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

await dynamo.send(new PutItemCommand({
  TableName: process.env.STEPS_TABLE,
  Item: {
    jornada_id: { S: jornada_id },
    step: { S: 'criar-envelope' },
    status: { S: 'ok' },
    recebido_em: { S: new Date().toISOString() },
  },
}));
```

## Consultar

```bash
# scan (POC/demo) ou query (prod, por jornada_id)
aws dynamodb scan --table-name jornada_steps
```

> **Regra operacional**: `query` por `jornada_id` (partição) é o padrão;
> `scan` só para demo/inspeção.

## Por que Dynamo e não Aurora para steps?

| | DynamoDB | Aurora PG |
|---|----------|-----------|
| Custo/velocidade | Serverless, escala automática | Provisionado |
| Uso recomendado | Steps/processo/estado | Dados de negócio |
| Premissa da spec | ✅ decisão do time | Banco principal (negócio) |
