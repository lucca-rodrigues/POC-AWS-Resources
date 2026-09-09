# AWS Lambda — Monitoramento e Debug

## CloudWatch Logs

Toda Lambda envia seus `console.log` para o **CloudWatch Logs** (log group
`/aws/lambda/<nome>`). É o principal lugar para ver o que a function fez.

```bash
# ver logs de uma function (floci)
bash scripts/logs.sh futurosign-health
```

Saída:
```
{"message":"postgres.item.salvo","data":{"id":"123","nome":"Lucas","stage":"dev"}}
```

## Logs estruturados (JSON)

Use logs em JSON — fáceis de filtrar e agrupar:

```javascript
function log(message, data = {}) {
  console.log(JSON.stringify({ message, data: { ...data, stage: STAGE } }));
}

log('kafka.evento.publicado', { id, tipo, topico: KAFKA_TOPIC });
```

> **Regra**: `message` é a frase (fixa), `data` são os valores (variáveis).
> Nunca interpole valores dentro da frase — impossibilita agrupar logs.

## Erros comuns e como debugar

| Sintoma | Causa provável | Como investigar |
|---------|----------------|-----------------|
| `Runtime.NodeJsExit` / Promise não resolvida | Um `await` travou (ex.: conexão sem timeout) | Ver logs; testar o handler isolado |
| `getaddrinfo ENOTFOUND` | Hostname não resolve (banco, kafka) | Testar conectividade de dentro do container |
| `InvalidAccessKeyId` | Provider/creds errados | Conferir `endpoints` no providers.tf |
| `Failed to start Lambda container` | Docker socket não montado | Conferir docker-compose |
| Timeout | Function demorou mais que o `timeout` | Aumentar timeout ou otimizar |

## Testar o handler isolado

Rode a imagem da function com um evento de teste (fora da AWS):

```bash
echo '{"Records":[{"messageId":"1","body":"{\"id\":\"x\",\"tipo\":\"t\"}"}]}' \
  | docker run -i --rm --network aws_default \
      -e STAGE=dev -e SECRET_NAME=futurosign/app \
      -e AWS_ENDPOINT_URL=http://simulador-aws:4566 \
      localhost:4566/futurosign-sqs:latest handler.handler
```

## Invocar via API Gateway (teste manual)

```bash
# health
curl http://localhost:4566/restapis/<id>/dev/_user_request_/health

# postgres (salva registro)
curl -X POST http://localhost:4566/restapis/<id>/dev/_user_request_/ \
  -H "Content-Type: application/json" \
  -d '{"id":"123","nome":"Lucas"}'
```

## Verificar cada serviço

```bash
# SQS: enviar mensagem
bash scripts/invoke-integracao.sh

# S3: listar objetos do bucket
curl http://localhost:4566/futurosign-artefatos

# Postgres: consultar (via container RDS)
docker exec <container-rds> psql -U postgres -d futurosign -c "SELECT * FROM postgres_itens;"

# Kafka: consumir tópico
docker exec futuro-kafka-local kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 --topic futurosign.integracao.status.tpc --from-beginning
```

## Dicas

- **Warm start**: clientes reutilizados entre invocações — se um cliente
  "quebrou", reinicie o container da Lambda (ou espere o cold start).
- **Timeouts**: defina timeouts nas conexões (pg, kafka) para não travar a
  invocação.
- **Logs em prod**: use o CloudWatch Logs Insights para filtrar por `message`.
