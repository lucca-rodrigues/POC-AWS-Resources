# Function: s3

Integração com **S3 (bucket)**. Recebe `{ id, conteudo }` via API Gateway,
salva o objeto no bucket e retorna o objeto lido.

## Comandos Terraform (manual)

```bash
cd terraform/environments/dev-local

terraform init          # prepara (baixa o provider aws)
terraform plan          # mostra o que será criado/alterado
terraform apply         # aplica (cria a infra da function)
terraform output api_gateway_s3_invoke_url   # URL de invocação
terraform output s3_bucket_name              # nome do bucket
terraform destroy       # destrói tudo (cuidado: destrói TODAS as functions)
```

> O `scripts/deploy.sh` faz isso automaticamente (build + init + apply).

## Invocar

```bash
# via script
bash scripts/invoke-functions.sh

# via curl (URL do output acima)
curl -X POST <api_gateway_s3_invoke_url> \
  -H "Content-Type: application/json" \
  -d '{"id":"s3-1","conteudo":"hello"}'
```

Saída esperada:

```json
{"objeto":{"id":"s3-1","conteudo":"hello","criadoEm":"..."},"key":"s3/s3-1.json"}
```

## Verificar o objeto no bucket

```bash
curl http://localhost:4566/futurosign-artefatos   # lista os objetos
```

## Logs

```bash
bash scripts/logs.sh futurosign-s3
```

## Infra (o que o Terraform cria)

| Recurso | Módulo |
|---------|--------|
| Repositório ECR (`futurosign-s3`) | `ecr` |
| Lambda (`futurosign-s3`) + IAM role | `lambda` |
| API Gateway (`futurosign-s3-api`) | `api-gateway` |
| Bucket S3 (`futurosign-artefatos`) | `s3` |
