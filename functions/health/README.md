# Function: health

Health check da POC. Responde `GET /health` com o status e o stage.

## Comandos Terraform (manual)

```bash
cd terraform/environments/dev-local

terraform init          # prepara (baixa o provider aws)
terraform plan          # mostra o que será criado/alterado
terraform apply         # aplica (cria a infra da function)
terraform output api_gateway_health_invoke_url   # URL de invocação
terraform destroy       # destrói tudo (cuidado: destrói TODAS as functions)
```

> O `scripts/deploy.sh` faz isso automaticamente (build + init + apply).

## Invocar

```bash
# via script
npm run invoke

# via curl (URL do output acima)
curl <api_gateway_health_invoke_url>/health
```

Saída esperada:

```json
{"status":"ok","stage":"dev"}
```

## Logs

```bash
bash scripts/logs.sh futurosign-health
```

## Infra (o que o Terraform cria)

| Recurso | Módulo |
|---------|--------|
| Repositório ECR (`futurosign-health`) | `ecr` |
| Lambda (`futurosign-health`) + IAM role | `lambda` |
| API Gateway (`futurosign-health-api`) | `api-gateway` |
