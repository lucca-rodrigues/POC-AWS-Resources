#!/usr/bin/env bash
# Deploy da POC FuturoSign no floci (emulador AWS local).
# Espelha o fluxo real de CI: build das imagens -> push ECR -> terraform apply.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$ROOT_DIR/terraform/environments/dev-local"
FLOCI_HEALTH="http://localhost:4566/_localstack/health"

echo "[1/4] Verificando se o floci esta rodando..."
if ! curl -s --max-time 5 "$FLOCI_HEALTH" >/dev/null 2>&1; then
  echo "ERRO: floci nao esta rodando. Execute: docker compose up -d"
  exit 1
fi

echo "[2/4] Build das imagens das functions..."
bash "$ROOT_DIR/scripts/build.sh"

echo "[3/4] Terraform init + apply (cria ECR, Lambdas, API Gateway, Secrets)..."
cd "$ENV_DIR"
terraform init >/dev/null
terraform apply -auto-approve

echo "[4/4] Push das imagens para o ECR do floci..."
for function_dir in "$ROOT_DIR"/functions/*/; do
  name="$(basename "$function_dir")"
  if docker push "localhost:4566/futurosign-$name:latest" 2>/dev/null; then
    echo "Push OK: futurosign-$name"
  else
    echo "Push ignorado ($name): o floci nao expoe registry de blobs; a imagem local ja esta no daemon."
  fi
done

echo "Deploy concluido! URLs de invocacao:"
terraform output
