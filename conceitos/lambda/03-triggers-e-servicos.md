# AWS Lambda — Triggers e Integrações (como a POC usa)

## API Gateway (HTTP)

O API Gateway expõe a Lambda como endpoint HTTP. O Terraform cria a API com
proxy `{proxy+}` (qualquer rota vai para a Lambda):

```hcl
# terraform/modules/api-gateway/main.tf (resumo)
resource "aws_api_gateway_rest_api" "this" {
  name = var.api_name
}

resource "aws_api_gateway_integration" "proxy" {
  type                    = "AWS_PROXY"   # repassa tudo para a Lambda
  uri                     = var.lambda_invoke_arn
}
```

```bash
# invocar
curl http://localhost:4566/restapis/<id>/dev/_user_request_/health
```

## SQS (fila)

O SQS é uma fila de mensagens. A Lambda é invocada quando há mensagem
(**event source mapping**):

```hcl
# terraform/environments/dev-local/main.tf
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = module.sqs.queue_arn
  function_name    = module.lambda_sqs.function_name
  batch_size       = 10
}
```

```javascript
// functions/sqs/src/handler.js — envia mensagem
await sqsClient.send(new SendMessageCommand({
  QueueUrl: SQS_QUEUE_URL,
  MessageBody: JSON.stringify({ id, tipo }),
}));
```

> **Particularidades AWS**: mensagem que falha é reenviada (retry); após N
> tentativas vai para a **DLQ** (fila de mensagens mortas).

## S3 (armazenamento)

O S3 guarda objetos (arquivos). A Lambda faz upload/download:

```javascript
// functions/s3/src/handler.js
await s3Client.send(new PutObjectCommand({
  Bucket: S3_BUCKET,
  Key: `s3/${id}.json`,
  Body: JSON.stringify({ id, conteudo }),
}));
```

## Postgres (RDS)

A Lambda conecta no banco via **Secrets Manager** (connection string fora do
código):

```javascript
// functions/postgres/src/handler.js
const config = await getConfig();   // lê o segredo
const client = new Client({ connectionString: toPgConnectionString(config.Database.ConnectionString) });
await client.query('INSERT INTO postgres_itens (id, nome) VALUES ($1, $2)', [id, nome]);
```

> A connection string fica no Secrets Manager (padrão da org) — a Lambda tem
> permissão IAM para ler (`secret_arns` no módulo lambda).

## Kafka (mensageria)

A Lambda publica eventos no Kafka (broker local da org):

```javascript
// functions/kafka/src/handler.js
const producer = await getKafkaProducer();
await producer.send({
  topic: KAFKA_TOPIC,
  messages: [{ key: id, value: JSON.stringify({ id, tipo, status: 'publicado' }) }],
});
```

## Resumo dos triggers por function

| Function | Trigger | O que faz |
|----------|---------|-----------|
| `health` | API Gateway | Retorna status |
| `postgres` | API Gateway | Salva/consulta no Postgres |
| `kafka` | API Gateway | Publica evento no Kafka |
| `sqs` | API Gateway + SQS | Envia e processa mensagens |
| `s3` | API Gateway | Upload/download no S3 |
