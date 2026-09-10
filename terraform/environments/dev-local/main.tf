# Ambiente dev-local: aponta para o floci (emulador AWS) e orquestra os modulos.
# Monorepo de functions: uma instancia dos modulos (ecr + lambda + api-gateway)
# por function em functions/. O provider (endpoints -> localhost:4566) esta em providers.tf.

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

# --- Segredo da aplicacao (config sensivel fora do codigo) ------------------
module "app_secret" {
  source = "../../modules/secrets-manager"

  name        = var.app_secret_name
  description = "Configuracao sensivel do FuturoSign (ex.: connection string, chaves de integracao)."

  secret_string = jsonencode({
    Stage = var.stage
    Database = {
      Provider = "PostgreSql"
      # O endpoint do cluster emulado e um hostname que so existe na API do floci; quem
      # precisa resolve-lo e o container da Lambda, entao db_host_override permite apontar
      # para o host real do container Postgres na rede docker.
      ConnectionString = "Host=${coalesce(var.db_host_override, module.aurora.cluster_endpoint)};Port=${coalesce(var.db_port_override, module.aurora.port)};Database=${var.db_name};Username=${var.master_username};Password=${var.master_password};SSL Mode=Disable"
    }
    Kafka = {
      BootstrapServers = aws_msk_cluster.this.bootstrap_brokers
      Topic            = var.kafka_topic
    }
  })
}

# --- Infra compartilhada (RDS, SQS, S3) -------------------------------------
module "aurora" {
  source = "../../modules/aurora-postgres"

  cluster_identifier = var.cluster_identifier
  database_name      = var.db_name
  master_username    = var.master_username
  engine_version     = var.engine_version
  instance_class     = var.instance_class

  # O floci nao implementa estes controles; o modulo nasce seguro e o dev-local desliga.
  manage_master_user_password = false
  master_password             = var.master_password
  storage_encrypted           = false
  backup_retention_period     = 1
  deletion_protection         = false
  skip_final_snapshot         = true
}

module "sqs" {
  source = "../../modules/sqs"

  queue_name = var.sqs_queue_name
}

module "s3" {
  source = "../../modules/s3"

  bucket_name = var.s3_bucket_name
}

# MSK (Kafka) emulado pelo floci — Redpanda na rede docker.
resource "aws_msk_cluster" "this" {
  cluster_name           = "futurosign-msk"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 1

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    client_subnets  = ["subnet-1"]
    security_groups = ["sg-1"]
  }

  # Adaptacao para emulador (floci): nao suporta UpdateSecurity. Em prod sao defaults — sem impacto.
  lifecycle {
    ignore_changes = [
      client_authentication,
      encryption_info,
      logging_info,
      open_monitoring,
      enhanced_monitoring,
    ]
  }
}

# --- Function: postgres (RDS) ------------------------------------------------
module "ecr_postgres" {
  source = "../../modules/ecr"

  repository_name = "futurosign-postgres"
}

module "lambda_postgres" {
  source = "../../modules/lambda"

  function_name = "futurosign-postgres"
  image_uri     = "localhost:4566/futurosign-postgres:latest"

  environment_variables = {
    STAGE       = var.stage
    SECRET_NAME = module.app_secret.name
  }

  secret_arns = [module.app_secret.arn]
}

module "api_gateway_postgres" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-postgres-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_postgres.invoke_arn
  lambda_function_name = module.lambda_postgres.function_name
}

# --- Function: kafka ---------------------------------------------------------
module "ecr_kafka" {
  source = "../../modules/ecr"

  repository_name = "futurosign-kafka"
}

module "lambda_kafka" {
  source = "../../modules/lambda"

  function_name = "futurosign-kafka"
  image_uri     = "localhost:4566/futurosign-kafka:latest"
  timeout       = 60

  environment_variables = {
    STAGE         = var.stage
    NODE_ENV      = "development"
    KAFKA_TOPIC   = var.kafka_topic
    KAFKA_BROKERS = aws_msk_cluster.this.bootstrap_brokers
  }
}

module "api_gateway_kafka" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-kafka-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_kafka.invoke_arn
  lambda_function_name = module.lambda_kafka.function_name
}

# --- Function: sqs ------------------------------------------------------------
module "ecr_sqs" {
  source = "../../modules/ecr"

  repository_name = "futurosign-sqs"
}

module "lambda_sqs" {
  source = "../../modules/lambda"

  function_name = "futurosign-sqs"
  image_uri     = "localhost:4566/futurosign-sqs:latest"

  environment_variables = {
    STAGE         = var.stage
    SQS_QUEUE_URL = module.sqs.queue_url
  }
}

# SQS trigger: a AWS invoca a function quando ha mensagem na fila.
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = module.sqs.queue_arn
  function_name    = module.lambda_sqs.function_name
  batch_size       = 10
}

module "api_gateway_sqs" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-sqs-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_sqs.invoke_arn
  lambda_function_name = module.lambda_sqs.function_name
}

# --- Function: s3 -------------------------------------------------------------
module "ecr_s3" {
  source = "../../modules/ecr"

  repository_name = "futurosign-s3"
}

module "lambda_s3" {
  source = "../../modules/lambda"

  function_name = "futurosign-s3"
  image_uri     = "localhost:4566/futurosign-s3:latest"

  environment_variables = {
    STAGE     = var.stage
    S3_BUCKET = module.s3.bucket_name
  }
}

module "api_gateway_s3" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-s3-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_s3.invoke_arn
  lambda_function_name = module.lambda_s3.function_name
}

# --- CRUD (TypeORM) — uma function por operacao ------------------------------
# create / read / update / delete em functions individuais (estudo).

module "ecr_crud_create" {
  source = "../../modules/ecr"

  repository_name = "futurosign-crud-create"
}

module "lambda_crud_create" {
  source = "../../modules/lambda"

  function_name = "futurosign-crud-create"
  image_uri     = "localhost:4566/futurosign-crud-create:latest"

  environment_variables = {
    STAGE       = var.stage
    SECRET_NAME = module.app_secret.name
  }

  secret_arns = [module.app_secret.arn]
}

module "api_gateway_crud_create" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-crud-create-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_crud_create.invoke_arn
  lambda_function_name = module.lambda_crud_create.function_name
}

module "ecr_crud_read" {
  source = "../../modules/ecr"

  repository_name = "futurosign-crud-read"
}

module "lambda_crud_read" {
  source = "../../modules/lambda"

  function_name = "futurosign-crud-read"
  image_uri     = "localhost:4566/futurosign-crud-read:latest"

  environment_variables = {
    STAGE       = var.stage
    SECRET_NAME = module.app_secret.name
  }

  secret_arns = [module.app_secret.arn]
}

module "api_gateway_crud_read" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-crud-read-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_crud_read.invoke_arn
  lambda_function_name = module.lambda_crud_read.function_name
}

module "ecr_crud_update" {
  source = "../../modules/ecr"

  repository_name = "futurosign-crud-update"
}

module "lambda_crud_update" {
  source = "../../modules/lambda"

  function_name = "futurosign-crud-update"
  image_uri     = "localhost:4566/futurosign-crud-update:latest"

  environment_variables = {
    STAGE       = var.stage
    SECRET_NAME = module.app_secret.name
  }

  secret_arns = [module.app_secret.arn]
}

module "api_gateway_crud_update" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-crud-update-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_crud_update.invoke_arn
  lambda_function_name = module.lambda_crud_update.function_name
}

module "ecr_crud_delete" {
  source = "../../modules/ecr"

  repository_name = "futurosign-crud-delete"
}

module "lambda_crud_delete" {
  source = "../../modules/lambda"

  function_name = "futurosign-crud-delete"
  image_uri     = "localhost:4566/futurosign-crud-delete:latest"

  environment_variables = {
    STAGE       = var.stage
    SECRET_NAME = module.app_secret.name
  }

  secret_arns = [module.app_secret.arn]
}

module "api_gateway_crud_delete" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-crud-delete-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_crud_delete.invoke_arn
  lambda_function_name = module.lambda_crud_delete.function_name
}




module "ecr_exemplo-http" {
  source = "../../modules/ecr"

  repository_name = "futurosign-exemplo-http"
}

module "lambda_exemplo-http" {
  source = "../../modules/lambda"

  function_name = "futurosign-exemplo-http"
  image_uri     = "localhost:4566/futurosign-exemplo-http:latest"

  environment_variables = {
    STAGE = var.stage
  }
}

module "api_gateway_exemplo-http" {
  source = "../../modules/api-gateway"

  api_name             = "futurosign-exemplo-http-api"
  stage_name           = var.api_gateway_stage
  lambda_invoke_arn    = module.lambda_exemplo-http.invoke_arn
  lambda_function_name = module.lambda_exemplo-http.function_name
}# --- Functions geradas (npm run gen) -----------------------------------------
