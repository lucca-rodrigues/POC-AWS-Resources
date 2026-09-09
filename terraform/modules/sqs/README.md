# Módulo SQS

Fila SQS com DLQ para processamento assíncrono (padrão de event-driven).

## Uso

```hcl
module "sqs" {
  source = "../../modules/sqs"

  queue_name = "futurosign-integracao"
}
```

## Recursos

- `aws_sqs_queue.this` — fila principal com redrive policy para a DLQ
- `aws_sqs_queue.dlq` — DLQ criada quando `dlq_arn` é null

## Outputs

- `queue_url` — URL da fila (enviar mensagens)
- `queue_arn` — ARN da fila (event source mapping)
- `dlq_arn` — ARN da DLQ
