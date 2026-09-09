#!/usr/bin/env bash
# Busca os logs da function no CloudWatch Logs do floci.
# Uso: bash scripts/logs.sh <nome-da-function> [limite]
set -euo pipefail

FUNCTION_NAME="${1:-futurosign-integracao}"
LIMIT="${2:-20}"
LOG_GROUP="/aws/lambda/$FUNCTION_NAME"

echo "== Logs de $LOG_GROUP (ultimos $LIMIT) =="

curl -s -X POST http://localhost:4566/ \
  -H "Content-Type: application/x-amz-json-1.0" \
  -H "X-Amz-Target: Logs.FilterLogEvents" \
  -d "{\"logGroupName\":\"$LOG_GROUP\",\"limit\":$LIMIT}" \
  | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    print('(sem resposta do floci)')
    sys.exit(0)
events = data.get('events', [])
if not events:
    print('(sem eventos de log)')
for e in events:
    print(e.get('message', ''))
"
