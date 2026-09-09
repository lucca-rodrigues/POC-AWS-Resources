# Modulo `api-gateway`

Provisiona uma **API Gateway REST (v1)** com integracao **AWS_PROXY** encaminhando
todas as rotas (`{proxy+}` + raiz) para uma Lambda, mais deployment, stage e a
`aws_lambda_permission` que autoriza o API Gateway a invocar a funcao.

Compativel com Lambdas que usam `LambdaEventSource.RestApi`. Funciona contra a AWS
real e contra o **ministack**.

## Uso

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"

  api_name             = "core-bancario-cliente-api"
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}
```

## Inputs

| Nome | Tipo | Default | Descricao |
|------|------|---------|-----------|
| `api_name` | string | — | Nome da API REST. |
| `lambda_invoke_arn` | string | — | `invoke_arn` da Lambda. |
| `lambda_function_name` | string | — | Nome da funcao (para a permission). |
| `stage_name` | string | `dev` | Nome do stage. |

## Outputs

| Nome | Descricao |
|------|-----------|
| `rest_api_id` | ID da API REST. |
| `stage_name` | Nome do stage. |
| `invoke_url` | URL de invocacao (formato AWS real). |
| `execution_arn` | execution_arn da API. |

## Invocacao no ministack

No ministack a URL segue o formato:

```
http://localhost:4566/restapis/<rest_api_id>/<stage>/_user_request_/<path>
```
