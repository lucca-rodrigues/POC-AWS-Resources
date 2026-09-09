# Terraform — O que é e para que serve

## O que é
Terraform é uma ferramenta de **Infraestrutura como Código (IaC)** da HashiCorp.
Você descreve a infraestrutura (servidores, bancos, filas, etc.) em arquivos de
código (`.tf`) e o Terraform cria, altera e destrói esses recursos na nuvem.

## Para que serve
- **Criar infra de forma declarativa**: você diz O QUE quer (ex.: "uma Lambda"),
  o Terraform descobre COMO criar.
- **Versionar a infra**: os arquivos `.tf` vão para o git — a infra vira código
  revisável, igual ao código da aplicação.
- **Reprodutibilidade**: o mesmo código cria o mesmo ambiente em dev, homolog e prod.
- **Destruir e recriar**: `terraform destroy` limpa tudo que foi criado.

## Conceitos-chave

| Conceito | O que é |
|----------|---------|
| **Provider** | Plugin que fala com a nuvem (ex.: `aws`). Configurado no `providers.tf` |
| **Resource** | Um recurso concreto (ex.: `aws_lambda_function`, `aws_s3_bucket`) |
| **Module** | Bloco reutilizável de recursos (ex.: módulo `lambda` usado por várias functions) |
| **State** | Arquivo que guarda o "mapa" do que foi criado (`terraform.tfstate`) |
| **Variable** | Entrada configurável (ex.: nome da function) |
| **Output** | Saída útil após o apply (ex.: URL da API) |

## Exemplo real (desta POC)

```hcl
# terraform/modules/lambda/main.tf (recurso)
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.exec.arn
  package_type  = "Image"
  image_uri     = var.image_uri
}
```

```hcl
# terraform/environments/dev-local/main.tf (uso do módulo)
module "lambda_health" {
  source = "../../modules/lambda"

  function_name = "futurosign-health"
  image_uri     = "localhost:4566/futurosign-health:latest"
}
```

## Fluxo de trabalho
```
escrever .tf → terraform init → terraform plan → terraform apply → terraform destroy
```

> Na POC, o `scripts/deploy.sh` roda `terraform init` + `terraform apply` automaticamente.
