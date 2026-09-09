# Function: postgres

Integração com **Postgres (RDS)**. Recebe `{ id, nome }` via API Gateway, persiste
na tabela `postgres_itens` e retorna o registro.

## Comandos Terraform (manual)

```bash
cd terraform/environments/dev-local

terraform init          # prepara (baixa o provider aws)
terraform plan          # mostra o que será criado/alterado
terraform apply         # aplica (cria a infra da function)
terraform output api_gateway_postgres_invoke_url   # URL de invocação
terraform destroy       # destrói tudo (cuidado: destrói TODAS as functions)
```

> O `scripts/deploy.sh` faz isso automaticamente (build + init + apply).

## Invocar

```bash
# via script
bash scripts/invoke-functions.sh

# via curl (URL do output acima)
curl -X POST <api_gateway_postgres_invoke_url> \
  -H "Content-Type: application/json" \
  -d '{"id":"pg-1","nome":"Lucas"}'
```

Saída esperada:

```json
{"registro":{"id":"pg-1","nome":"Lucas","criado_em":"..."}}
```

## Logs

```bash
bash scripts/logs.sh futurosign-postgres
```

## Infra (o que o Terraform cria)

| Recurso | Módulo |
|---------|--------|
| Repositório ECR (`futurosign-postgres`) | `ecr` |
| Lambda (`futurosign-postgres`) + IAM role | `lambda` |
| API Gateway (`futurosign-postgres-api`) | `api-gateway` |
| Cluster RDS (compartilhado) | `aurora-postgres` |
| Segredo com connection string | `secrets-manager` |
