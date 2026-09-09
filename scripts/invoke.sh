#!/usr/bin/env bash
# Invoca as functions publicadas via API Gateway (floci).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$ROOT_DIR/terraform/environments/dev-local"

cd "$ENV_DIR"
HEALTH_URL="$(terraform output -raw api_gateway_health_invoke_url)"
PING_URL="$(terraform output -raw api_gateway_ping_invoke_url)"

echo "== GET /health (function health) =="
curl -s "$HEALTH_URL/health"
echo
echo "== GET /ping (function ping) =="
curl -s "$PING_URL/ping"
echo
