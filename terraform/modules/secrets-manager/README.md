# Modulo `secrets-manager`

Provisiona um segredo no **AWS Secrets Manager** (`aws_secretsmanager_secret` +
`aws_secretsmanager_secret_version`) com o JSON de configuracao sensivel da
aplicacao (connection string do Aurora, `LYD-Certificado`).

Funciona contra a AWS real e contra o **ministack** (emulador local).

## Uso

```hcl
module "app_secret" {
  source = "./modules/secrets-manager"

  name = "core-bancario/cliente"

  secret_string = jsonencode({
    ConnectionStrings = { DefaultConnection = "Host=...;Password=..." }
    Lydians           = { Certificado = "..." }
  })
}
```

## Inputs

| Nome | Tipo | Default | Descricao |
|------|------|---------|-----------|
| `name` | string | — | Nome do segredo. |
| `description` | string | `""` | Descricao do segredo. |
| `secret_string` | string (sensitive) | — | Conteudo JSON do segredo. |
| `recovery_window_in_days` | number | `0` | Janela de recuperacao; 0 permite recriar imediatamente (dev). |

## Outputs

| Nome | Descricao |
|------|-----------|
| `arn` | ARN do segredo (para policies IAM). |
| `name` | Nome do segredo (para `SecretsManager__SecretId`). |

> Nota: o valor do segredo fica no state do Terraform. Em ambientes reais,
> use state remoto criptografado e injete os valores via variaveis de pipeline.
