# Function: sqs

Integração com **SQS (fila)**. Duas formas de uso:
1. **API Gateway**: recebe `{ id, tipo }` e **envia** mensagem para a fila.
2. **SQS trigger**: a AWS **invoca** a function quando há mensagem na fila
   (processa `event.Records`).

## Comandos Terraform (manual)

```bash
cd terraform/environments/dev-local

terraform init          # prepara (baixa o provider aws)
terraform plan          # mostra o que será criado/alterado
terraform apply         # aplica (cria a infra da function)
terraform output api_gateway_sqs_invoke_url   # URL de invocação
terraform output sqs_queue_url                # URL da fila
terraform destroy       # destrói tudo (cuidado: destrói TODAS as functions)
```

> O `scripts/deploy.sh` faz isso automaticamente (build + init + apply).

## Invocar

```bash
# via script (testa as 4 functions de integração)
bash scripts/invoke-functions.sh

# envia mensagem SQS (dispara o trigger)
bash scripts/invoke-integracao.sh

# via curl (URL do output acima)
curl -X POST <api_gateway_sqs_invoke_url> \
  -H "Content-Type: application/json" \
  -d '{"id":"sqs-1","tipo":"teste"}'
```

Saída esperada (API GW):

```json
{"status":"enviado","fila":"http://localhost:4566/000000000000/futurosign-integracao"}
```

## Logs

```bash
bash scripts/logs.sh futurosign-sqs
```

## Infra (o que o Terraform cria)

| Recurso | Módulo |
|---------|--------|
| Repositório ECR (`futurosign-sqs`) | `ecr` |
| Lambda (`futurosign-sqs`) + IAM role | `lambda` |
| API Gateway (`futurosign-sqs-api`) | `api-gateway` |
| Fila SQS + DLQ (`futurosign-integracao`) | `sqs` |
| Event source mapping (SQS → Lambda) | resource direto |
