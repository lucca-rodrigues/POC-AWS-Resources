# Terraform — Módulos, Variáveis e Outputs

## Variáveis (entradas)

Variáveis tornam o código reutilizável. Você define com `variable` e usa com `var.`:

```hcl
# terraform/environments/dev-local/variables.tf
variable "stage" {
  description = "Stage da aplicacao (injetado como env var nas functions)."
  type        = string
  default     = "dev"
}
```

```hcl
# uso
environment_variables = {
  STAGE = var.stage
}
```

| Tipo | Exemplo |
|------|---------|
| `string` | `"dev"` |
| `number` | `512` |
| `bool` | `true` |
| `list(string)` | `["x86_64"]` |
| `map(string)` | `{ STAGE = "dev" }` |

## Módulos (blocos reutilizáveis)

Um módulo é um conjunto de recursos empacotado. Nesta POC, o módulo `lambda`
cria a IAM role + a function — e é usado por **cada function** do monorepo:

```hcl
# terraform/modules/lambda/main.tf (dentro do módulo)
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.exec.arn
  package_type  = "Image"
  image_uri     = var.image_uri
}
```

```hcl
# uso do módulo (no dev-local/main.tf)
module "lambda_health" {
  source = "../../modules/lambda"   # caminho do módulo

  function_name = "futurosign-health"
  image_uri     = "localhost:4566/futurosign-health:latest"
}
```

> **Vantagem**: para adicionar uma function nova, basta copiar o bloco `module`
> e trocar os nomes — a infra (role, function, etc.) vem pronta do módulo.

## Outputs (saídas)

Outputs expõem valores úteis após o apply (URLs, nomes, ARNs):

```hcl
# terraform/environments/dev-local/outputs.tf
output "api_gateway_health_invoke_url" {
  description = "URL de invocacao da function health."
  value       = "http://localhost:4566/restapis/${module.api_gateway_health.rest_api_id}/dev/_user_request_"
}
```

```bash
terraform output api_gateway_health_invoke_url   # mostra só a URL
terraform output                                  # mostra todos
```

## Estrutura da POC

```
terraform/
├── environments/
│   └── dev-local/          # ambiente local (orquestra os módulos)
│       ├── main.tf         # usa os módulos (ecr + lambda + api-gateway por function)
│       ├── providers.tf    # provider apontando para o floci
│       ├── variables.tf    # entradas
│       ├── outputs.tf      # saídas
│       └── versions.tf     # versões do terraform/provider
└── modules/                # blocos reutilizáveis
    ├── lambda/             # IAM role + function
    ├── api-gateway/        # API REST + proxy para a Lambda
    ├── ecr/                # repositório de imagem
    ├── secrets-manager/    # segredo (config sensível)
    ├── sqs/                # fila + DLQ
    └── s3/                 # bucket
```

## Dependências entre recursos

O Terraform resolve dependências automaticamente. Ex.: a Lambda precisa do ARN
da role — o Terraform cria a role primeiro:

```hcl
resource "aws_lambda_function" "this" {
  role = aws_iam_role.exec.arn   # depende de aws_iam_role.exec
}
```

> Referências a outros recursos (`aws_iam_role.exec.arn`) criam a ordem de criação.
