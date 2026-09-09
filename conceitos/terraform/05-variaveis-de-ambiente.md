# Terraform — Variáveis de Ambiente (POC vs Prod)

## Como definir env vars no Terraform

As variáveis de ambiente da Lambda são definidas no bloco `environment_variables`
do módulo `lambda`:

```hcl
# terraform/environments/dev-local/main.tf
module "lambda_health" {
  source = "../../modules/lambda"

  function_name = "futurosign-health"
  image_uri     = "localhost:4566/futurosign-health:latest"

  environment_variables = {
    STAGE = var.stage
  }
}
```

> O módulo `lambda` injeta essas variáveis na function via
> `aws_lambda_function.environment.variables`.

## Regra de ouro: o que vai em env var vs Secrets Manager

| Tipo de config | Onde fica | Exemplos |
|----------------|-----------|----------|
| **Não sensível** | Env var | `STAGE`, `SECRET_NAME` (nome do segredo), `KAFKA_TOPIC`, `S3_BUCKET` |
| **Sensível** | **Secrets Manager** | connection string, senhas, certificados, chaves de API |

> **Nunca coloque segredo em env var.** A Lambda lê o segredo via SDK com
> permissão IAM (`secret_arns`).

## Como a POC carrega

```hcl
# 1. Env vars (não sensíveis) — definidas no terraform
environment_variables = {
  STAGE       = var.stage
  SECRET_NAME = module.app_secret.name   # só o NOME do segredo
}

# 2. Segredo (sensível) — connection string, brokers Kafka
secret_arns = [module.app_secret.arn]    # permissão IAM de leitura
```

```javascript
// 3. No handler (Node): lê env var + busca o segredo via SDK
const STAGE = process.env.STAGE ?? 'dev';
const SECRET_NAME = process.env.SECRET_NAME;

const response = await secretsClient.send(
  new GetSecretValueCommand({ SecretId: SECRET_NAME })
);
const config = JSON.parse(response.SecretString);
// config.Database.ConnectionString, config.Kafka.BootstrapServers, ...
```

## POC (floci) vs Prod (AWS real)

| Aspecto | POC (floci) | Prod (AWS real) |
|---------|-------------|-----------------|
| Env vars | Definidas no terraform (`environment_variables`) | **Mesma coisa** — o terraform injeta |
| Segredos | Secrets Manager do floci (`localhost:4566`) | Secrets Manager real (mesmo código) |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | Injetadas pelo floci (creds dummy) | **Injetadas pelo runtime da Lambda** — não configure |
| `AWS_REGION` | Injetada pelo floci | Injetada pelo runtime |
| Endpoint AWS | `AWS_ENDPOINT_URL` (floci injeta) | **Não existe** — SDK usa a AWS real |

> **Importante**: em prod, as variáveis `AWS_*` são reservadas e injetadas pelo
> runtime da Lambda. Não as defina no terraform para prod — só o floci precisa
> (e ele injeta sozinho).

## Fluxo completo (POC)

```
terraform (environment_variables) ──> Lambda (process.env)
terraform (secret_arns) ──> IAM permissão ──> Lambda lê Secrets Manager (SDK)
```

## Verificar as env vars de uma function

```bash
# no floci
curl http://localhost:4566/2015-03-31/functions/futurosign-health/configuration \
  | python3 -m json.tool | grep -A5 Environment
```
