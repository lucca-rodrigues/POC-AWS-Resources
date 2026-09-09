# AWS Lambda — Handler, Eventos e Resposta

## O handler

Toda Lambda exporta uma função `handler` que a AWS invoca:

```javascript
// functions/health/src/handler.js
'use strict';

const STAGE = process.env.STAGE ?? 'dev';

exports.handler = async () => ({
  statusCode: 200,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'ok', stage: STAGE }),
});
```

> O `CMD ["handler.handler"]` no Dockerfile diz: "arquivo `handler.js`, função `handler`".

## O evento (entrada)

O evento é o JSON que dispara a Lambda. O formato muda conforme o trigger:

**Via API Gateway** (HTTP):
```json
{
  "body": "{\"id\":\"123\",\"nome\":\"Lucas\"}",
  "httpMethod": "POST",
  "path": "/"
}
```

**Via SQS** (fila):
```json
{
  "Records": [
    { "messageId": "abc-123", "body": "{\"id\":\"123\",\"tipo\":\"teste\"}" }
  ]
}
```

## A resposta (saída)

Para API Gateway, a Lambda retorna uma **resposta HTTP** no formato proxy:

```javascript
{
  statusCode: 200,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'ok' })
}
```

Para SQS, a Lambda retorna o controle de falhas do batch:

```javascript
return { batchItemFailures: [{ itemIdentifier: record.messageId }] };
// mensagens que falharam são reenviadas pela AWS
```

## Variáveis de ambiente

A Lambda recebe config via env vars (definidas no Terraform):

```hcl
# terraform/environments/dev-local/main.tf
environment_variables = {
  STAGE       = var.stage
  SECRET_NAME = module.app_secret.name
}
```

```javascript
// no handler
const STAGE = process.env.STAGE ?? 'dev';
```

## Logs estruturados (padrão da org)

Logs em JSON com `message` (frase) e `data` (metadados) — fáceis de filtrar:

```javascript
function log(message, data = {}) {
  console.log(JSON.stringify({ message, data: { ...data, stage: STAGE } }));
}

log('postgres.item.salvo', { id, nome });
// {"message":"postgres.item.salvo","data":{"id":"123","nome":"Lucas","stage":"dev"}}
```

## Warm start (reuso de clientes)

Clientes (Postgres, Kafka, S3) são criados **fora** do handler e reutilizados
entre invocações — evita reconectar a cada chamada:

```javascript
let pgClient = null;

async function getPgClient() {
  if (pgClient) return pgClient;   // reutiliza se já conectou
  pgClient = new Client({ connectionString });
  await pgClient.connect();
  return pgClient;
}
```
