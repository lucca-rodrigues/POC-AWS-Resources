output "lambda_functions" {
  description = "Nomes das functions Lambda do monorepo."
  value = {
    health       = module.lambda_health.function_name
    postgres     = module.lambda_postgres.function_name
    kafka        = module.lambda_kafka.function_name
    sqs          = module.lambda_sqs.function_name
    s3           = module.lambda_s3.function_name
    crud_create  = module.lambda_crud_create.function_name
    crud_read    = module.lambda_crud_read.function_name
    crud_update  = module.lambda_crud_update.function_name
    crud_delete  = module.lambda_crud_delete.function_name
  }
}

output "app_secret_name" {
  description = "Nome do segredo da aplicacao."
  value       = module.app_secret.name
}

output "api_gateway_health_invoke_url" {
  description = "URL de invocacao da function health no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_health.rest_api_id}/${module.api_gateway_health.stage_name}/_user_request_"
}

output "api_gateway_postgres_invoke_url" {
  description = "URL de invocacao da function postgres no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_postgres.rest_api_id}/${module.api_gateway_postgres.stage_name}/_user_request_"
}

output "api_gateway_kafka_invoke_url" {
  description = "URL de invocacao da function kafka no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_kafka.rest_api_id}/${module.api_gateway_kafka.stage_name}/_user_request_"
}

output "api_gateway_sqs_invoke_url" {
  description = "URL de invocacao da function sqs no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_sqs.rest_api_id}/${module.api_gateway_sqs.stage_name}/_user_request_"
}

output "api_gateway_s3_invoke_url" {
  description = "URL de invocacao da function s3 no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_s3.rest_api_id}/${module.api_gateway_s3.stage_name}/_user_request_"
}

output "api_gateway_crud_create_invoke_url" {
  description = "URL de invocacao da function crud-create no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_crud_create.rest_api_id}/${module.api_gateway_crud_create.stage_name}/_user_request_"
}

output "api_gateway_crud_read_invoke_url" {
  description = "URL de invocacao da function crud-read no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_crud_read.rest_api_id}/${module.api_gateway_crud_read.stage_name}/_user_request_"
}

output "api_gateway_crud_update_invoke_url" {
  description = "URL de invocacao da function crud-update no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_crud_update.rest_api_id}/${module.api_gateway_crud_update.stage_name}/_user_request_"
}

output "api_gateway_crud_delete_invoke_url" {
  description = "URL de invocacao da function crud-delete no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_crud_delete.rest_api_id}/${module.api_gateway_crud_delete.stage_name}/_user_request_"
}

output "sqs_queue_url" {
  description = "URL da fila SQS de entrada da function sqs."
  value       = module.sqs.queue_url
}

output "s3_bucket_name" {
  description = "Nome do bucket S3 de artefatos."
  value       = module.s3.bucket_name
}

output "aurora_cluster_endpoint" {
  description = "Endpoint do cluster Aurora (RDS)."
  value       = module.aurora.cluster_endpoint
}


output "api_gateway_exemplo-http_invoke_url" {
  description = "URL de invocacao da function exemplo-http no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_exemplo-http.rest_api_id}/${module.api_gateway_exemplo-http.stage_name}/_user_request_"
}

# --- Outputs gerados (npm run gen) ------------------------------------------
