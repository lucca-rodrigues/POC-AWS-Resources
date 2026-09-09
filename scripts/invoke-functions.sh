#!/usr/bin/env bash
# Invoca as functions de integracao via API Gateway (floci) com payloads de teste.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$ROOT_DIR/terraform/environments/dev-local"

cd "$ENV_DIR"

invoke() {
  local name="$1"
  local payload="$2"
  local url
  url="$(terraform output -raw "api_gateway_${name}_invoke_url")"
  echo "== $name =="
  curl -s -X POST "$url" -H "Content-Type: application/json" -d "$payload"
  echo
}

invoke postgres '{"id":"pg-1","nome":"Lucas"}'
invoke kafka '{"id":"kf-1","tipo":"teste"}'
invoke sqs '{"id":"sqs-1","tipo":"teste"}'
invoke s3 '{"id":"s3-1","conteudo":"hello"}'
