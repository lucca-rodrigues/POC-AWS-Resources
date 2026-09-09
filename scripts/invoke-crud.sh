#!/usr/bin/env bash
# Testa o CRUD completo (create -> read -> update -> delete) via API Gateway.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$ROOT_DIR/terraform/environments/dev-local"

cd "$ENV_DIR"

CREATE_URL="$(terraform output -raw api_gateway_crud_create_invoke_url)"
READ_URL="$(terraform output -raw api_gateway_crud_read_invoke_url)"
UPDATE_URL="$(terraform output -raw api_gateway_crud_update_invoke_url)"
DELETE_URL="$(terraform output -raw api_gateway_crud_delete_invoke_url)"

echo "== CREATE =="
CREATE_RESPONSE="$(curl -s -X POST "$CREATE_URL" -H "Content-Type: application/json" -d '{"nome":"Item de teste"}')"
echo "$CREATE_RESPONSE"
ID="$(echo "$CREATE_RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin)['item']['id'])")"

echo "== READ (todos) =="
curl -s -X POST "$READ_URL" -H "Content-Type: application/json" -d '{}' | python3 -c "import json,sys; d=json.load(sys.stdin); print('total:', len(d['itens']))"

echo "== READ (por id) =="
curl -s -X POST "$READ_URL" -H "Content-Type: application/json" -d "{\"id\":\"$ID\"}"

echo
echo "== UPDATE =="
curl -s -X POST "$UPDATE_URL" -H "Content-Type: application/json" -d "{\"id\":\"$ID\",\"nome\":\"Item atualizado\"}"

echo
echo "== DELETE =="
curl -s -X POST "$DELETE_URL" -H "Content-Type: application/json" -d "{\"id\":\"$ID\"}"
echo
