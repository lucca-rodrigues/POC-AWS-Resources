# Ambiente dev-local: aponta para o floci (emulador AWS) e orquestra os modulos.
# Monorepo de functions: uma instancia dos modulos (ecr + lambda + api-gateway)
# por function em functions/, exatamente como cada repo core-bancario faz.
# O provider (endpoints -> localhost:4566) esta em providers.tf.

# --- Function: health -------------------------------------------------------
module "ecr_health" {
  source = "../../modules/ecr"

  repository_name = "futurosign-health"
}

module "lambda_health" {
  source = "../../modules/lambda"

  function_name = "futurosign-health"
  image_uri     = "localhost:4566/futurosign-health:latest"

  environment_variables = {
    STAGE = var.stage
  }
}

module "api_gateway_health" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-health-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_health.invoke_arn
  lambda_function_name = module.lambda_health.function_name
}

# --- Function: ping ---------------------------------------------------------
module "ecr_ping" {
  source = "../../modules/ecr"

  repository_name = "futurosign-ping"
}

module "lambda_ping" {
  source = "../../modules/lambda"

  function_name = "futurosign-ping"
  image_uri     = "localhost:4566/futurosign-ping:latest"

  environment_variables = {
    STAGE = var.stage
  }
}

module "api_gateway_ping" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-ping-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_ping.invoke_arn
  lambda_function_name = module.lambda_ping.function_name
}

# --- Segredo da aplicacao (config sensivel fora do codigo) ------------------
module "app_secret" {
  source = "../../modules/secrets-manager"

  name        = var.app_secret_name
  description = "Configuracao sensivel do FuturoSign (ex.: connection string, chaves de integracao)."

  secret_string = jsonencode({
    Stage = var.stage
    # TODO: adicionar chaves reais do FuturoSign (ex.: Database, Integracoes)
  })
}
