# Terraform — Como usar (init, plan, apply, destroy)

## Comandos essenciais

| Comando | O que faz |
|---------|-----------|
| `terraform init` | Baixa os providers e prepara o diretório (primeira vez) |
| `terraform plan` | Mostra o que será criado/alterado/destruído (sem aplicar) |
| `terraform apply` | Aplica as mudanças (cria/atualiza recursos) |
| `terraform destroy` | Destrói tudo que foi criado |
| `terraform output` | Mostra os outputs (URLs, nomes) |
| `terraform validate` | Valida a sintaxe dos arquivos `.tf` |

## Fluxo típico

```bash
cd terraform/environments/dev-local

terraform init      # 1. prepara (baixa o provider aws)
terraform plan      # 2. confere o que vai mudar
terraform apply     # 3. aplica (cria os recursos)
terraform output    # 4. vê as URLs/nomes criados
```

> `terraform apply -auto-approve` pula a confirmação manual (usado nos scripts).

## Providers

O provider diz ao Terraform **onde** criar os recursos. Nesta POC, o provider
aponta para o **floci** (emulador AWS local) em vez da AWS real:

```hcl
# terraform/environments/dev-local/providers.tf
provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  endpoints {
    lambda         = "http://localhost:4566"
    apigateway     = "http://localhost:4566"
    s3             = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
  }
}
```

> **Importante**: cada serviço AWS usado precisa de um `endpoints` apontando para
> o emulador. Sem isso, o Terraform tenta falar com a AWS **real**.

## State

- O `terraform.tfstate` guarda o que foi criado (é o "banco de dados" da infra).
- **Nunca edite na mão** — o Terraform gerencia.
- Em dev é descartável: apagou o state, `terraform apply` recria tudo.
- **Nunca versionar** (contém segredos) — está no `.gitignore`.

## Na POC

```bash
npm run deploy   # build das functions + terraform init + apply
npm run invoke   # chama as rotas via API Gateway
```

> Para limpar tudo: `cd terraform/environments/dev-local && terraform destroy -auto-approve`
