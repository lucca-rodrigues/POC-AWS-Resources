# Modulo `lambda`

Provisiona uma funcao **AWS Lambda** empacotada como **imagem de container**
(`package_type = "Image"`), junto com um role de execucao IAM basico.

Funciona contra a AWS real e contra o **ministack** (emulador local). No ministack,
a funcao e executada em um container Docker a partir da imagem do ECR.

## Uso

```hcl
module "lambda" {
  source = "./modules/lambda"

  function_name = "core-bancario-cliente-lambda"
  image_uri     = "${module.ecr.repository_url}:latest"

  environment_variables = {
    ConnectionStrings__DefaultConnection = "Host=...;Port=5432;Database=core_bancario_cliente;..."
  }
}
```

## Inputs

| Nome | Tipo | Default | Descricao |
|------|------|---------|-----------|
| `function_name` | string | — | Nome da funcao. |
| `image_uri` | string | — | URI da imagem no ECR (com tag). |
| `timeout` | number | `30` | Timeout em segundos. |
| `memory_size` | number | `512` | Memoria (MB). |
| `architectures` | list(string) | `["x86_64"]` | Arquiteturas da imagem. |
| `environment_variables` | map(string) | `{}` | Variaveis de ambiente. |

## Outputs

| Nome | Descricao |
|------|-----------|
| `function_name` | Nome da funcao. |
| `function_arn` | ARN da funcao. |
| `invoke_arn` | ARN de invocacao (API Gateway). |
| `role_arn` | ARN do role de execucao. |
