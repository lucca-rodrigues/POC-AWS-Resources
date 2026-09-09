output "lambda_functions" {
  description = "Nomes das functions Lambda do monorepo."
  value = {
    health = module.lambda_health.function_name
    ping   = module.lambda_ping.function_name
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

output "api_gateway_ping_invoke_url" {
  description = "URL de invocacao da function ping no floci (localhost:4566)."
  value       = "http://localhost:4566/restapis/${module.api_gateway_ping.rest_api_id}/${module.api_gateway_ping.stage_name}/_user_request_"
}
