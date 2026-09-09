# Function: exemplo-http

Function HTTP de exemplo (referencia)

## Comandos Terraform (manual)

```bash
cd terraform/environments/dev-local

terraform init          # prepara (baixa o provider aws)
terraform plan          # mostra o que será criado/alterado
terraform apply         # aplica (cria a infra da function)
terraform output api_gateway_exemplo-http_invoke_url   # URL de invocação
terraform destroy       # destrói tudo (cuidado: destrói TODAS as functions)
```

> O `scripts/deploy.sh` faz isso automaticamente (build + init + apply).

## Invocar

```bash
# via curl (URL do output acima)
curl -X POST <api_gateway_exemplo-http_invoke_url> \
  -H "Content-Type: application/json" \
  -d '{}'
```

## Logs

```bash
bash scripts/logs.sh futurosign-exemplo-http
```

## Infra (o que o Terraform cria)

| Recurso | Módulo |
|---------|--------|
| Repositório ECR (`futurosign-exemplo-http`) | `ecr` |
| Lambda (`futurosign-exemplo-http`) + IAM role | `lambda` |
| API Gateway (`futurosign-exemplo-http-api`) | `api-gateway` |
