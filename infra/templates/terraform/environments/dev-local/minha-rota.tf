# Function: minha-rota — declaracao no terraform.
# Copie este bloco para o terraform/environments/dev-local/main.tf
# (ou use o arquivo minha-rota.tf gerado, incluindo-o no main.tf).

module "ecr_minha-rota" {
  source = "../../modules/ecr"

  repository_name = "futurosign-minha-rota"
}

module "lambda_minha-rota" {
  source = "../../modules/lambda"

  function_name = "futurosign-minha-rota"
  image_uri     = "localhost:4566/futurosign-minha-rota:latest"

  environment_variables = {
    STAGE = var.stage
  }
}

module "api_gateway_minha-rota" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-minha-rota-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_minha-rota.invoke_arn
  lambda_function_name = module.lambda_minha-rota.function_name
}
