# AWS Lambda — Variáveis de Ambiente e Configuração

## Como a Lambda recebe env vars

As env vars são definidas no **Terraform** (bloco `environment_variables` do
módulo `lambda`) e a Lambda as lê via `process.env`:

```hcl
# terraform (define)
environment_variables = {
  STAGE       = var.stage
  SECRET_NAME = module.app_secret.name
}
```

```javascript
// handler (lê)
const STAGE = process.env.STAGE ?? 'dev';
const SECRET_NAME = process.env.SECRET_NAME;
```

## Regra: env var para config não sensível, Secrets Manager para sensível

| Tipo | Onde | Exemplo |
|------|------|---------|
| Não sensível | Env var | `STAGE`, `KAFKA_TOPIC`, `S3_BUCKET` |
| Sensível | Secrets Manager | connection string, senhas, chaves |

> A Lambda recebe **permissão IAM** (`secret_arns`) para ler o segredo — nunca
> coloque a senha em env var.

## Lendo o Secrets Manager (padrão da org)

```javascript
// handler — lê o segredo via SDK com cache (não busca a cada invocação)
let configCache = null;

async function getConfig() {
  if (configCache) return configCache;
  const response = await secretsClient.send(
    new GetSecretValueCommand({ SecretId: SECRET_NAME })
  );
  configCache = JSON.parse(response.SecretString);
  return configCache;
}

// uso
const config = await getConfig();
const connectionString = config.Database.ConnectionString;
const brokers = config.Kafka.BootstrapServers;
```

> Equivalente ao `AddAwsSecretsManager` dos repos .NET (que carrega no startup).

## POC (floci) vs Prod (AWS real)

| Aspecto | POC (floci) | Prod (AWS real) |
|---------|-------------|-----------------|
| Env vars | Terraform injeta | **Mesma coisa** |
| Segredos | Secrets Manager do floci | Secrets Manager real (mesmo código) |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | floci injeta (dummy) | **Runtime injeta** — não configure |
| `AWS_REGION` | floci injeta | Runtime injeta |
| `AWS_ENDPOINT_URL` | floci injeta (`http://localhost.floci.io:4566`) | **Não existe** — SDK usa AWS real |

> **Importante**: o código do handler é o **mesmo** em POC e prod. Só muda o
> ambiente (floci vs AWS real) — as env vars `AWS_*` e o endpoint são resolvidos
> automaticamente.

## Particularidades da Lambda

- **Env vars são imutáveis em runtime**: para mudar, reaplique o terraform
  (ou use `aws lambda update-function-configuration`).
- **Limite**: até 4 KB de env vars por function.
- **Warm start**: o `configCache` persiste entre invocações — se o segredo
  mudar, reinicie o container (cold start) para recarregar.
- **Nunca logue segredos**: não faça `console.log(config.Database.Password)`.

## Exemplo real (function postgres)

```hcl
# terraform
environment_variables = {
  STAGE       = var.stage
  SECRET_NAME = module.app_secret.name   # nome do segredo
}
secret_arns = [module.app_secret.arn]    # permissão IAM
```

```javascript
// handler
const config = await getConfig();
const client = new Client({
  connectionString: toPgConnectionString(config.Database.ConnectionString),
});
```
