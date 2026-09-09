#!/usr/bin/env bash
# Envia uma mensagem SQS de teste para a function integracao (floci).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$ROOT_DIR/terraform/environments/dev-local"

cd "$ENV_DIR"
QUEUE_URL="$(terraform output -raw sqs_queue_url)"

MESSAGE="{\"id\":\"$(date +%s)\",\"tipo\":\"teste\"}"

echo "Enviando mensagem para $QUEUE_URL"
echo "Payload: $MESSAGE"

python3 - "$QUEUE_URL" "$MESSAGE" << 'EOF'
import json, sys, urllib.request

queue_url, message = sys.argv[1], sys.argv[2]
body = json.dumps({"QueueUrl": queue_url, "MessageBody": message}).encode()

req = urllib.request.Request(
    "http://localhost:4566/",
    data=body,
    method="POST",
    headers={
        "Content-Type": "application/x-amz-json-1.0",
        "X-Amz-Target": "AmazonSQS.SendMessage",
    },
)
print(urllib.request.urlopen(req).read().decode())
EOF
