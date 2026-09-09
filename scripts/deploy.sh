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

# Conecta o Kafka local a rede do floci com alias 'kafka' (listener interno).
# Necessario para a function kafka publicar eventos de dentro do container Lambda.
if docker ps --format '{{.Names}}' | grep -q '^futuro-kafka-local$'; then
  docker network connect --alias kafka aws_default futuro-kafka-local 2>/dev/null || true
fi

echo "[2/4] Build das imagens das functions..."
bash "$ROOT_DIR/scripts/build.sh"

echo "[3/4] Terraform init + apply (cria ECR, Lambdas, API Gateway, Secrets)..."
cd "$ENV_DIR"
terraform init >/dev/null

# O floci retorna o endpoint do RDS como o IP dele mesmo; o container Postgres
# real responde pelo nome (Docker DNS). Descobre o nome e usa como override.
RDS_CONTAINER="$(docker ps --filter "name=floci-rds" --format '{{.Names}}' | head -1 || true)"
EXTRA_VARS=()
if [ -n "$RDS_CONTAINER" ]; then
  EXTRA_VARS=(-var="db_host_override=$RDS_CONTAINER" -var="db_port_override=5432")
fi

terraform apply -auto-approve "${EXTRA_VARS[@]}"

# Primeira execucao: o RDS foi criado agora — reaplica com o override correto.
if [ -z "$RDS_CONTAINER" ]; then
  RDS_CONTAINER="$(docker ps --filter "name=floci-rds" --format '{{.Names}}' | head -1 || true)"
  if [ -n "$RDS_CONTAINER" ]; then
    echo "RDS criado agora — reaplicando com override ($RDS_CONTAINER)..."
    terraform apply -auto-approve -var="db_host_override=$RDS_CONTAINER" -var="db_port_override=5432"
  fi
fi

echo "[4/4] Push das imagens para o ECR do floci..."
for function_dir in "$ROOT_DIR"/functions/*/; do
  name="$(basename "$function_dir")"
  if [ -f "$function_dir/Dockerfile" ]; then
    if docker push "localhost:4566/futurosign-$name:latest" 2>/dev/null; then
      echo "Push OK: futurosign-$name"
    else
      echo "Push ignorado ($name): o floci nao expoe registry de blobs; a imagem local ja esta no daemon."
    fi
  else
    for sub_dir in "$function_dir"*/; do
      sub_name="$(basename "$sub_dir")"
      if docker push "localhost:4566/futurosign-$name-$sub_name:latest" 2>/dev/null; then
        echo "Push OK: futurosign-$name-$sub_name"
      else
        echo "Push ignorado ($name-$sub_name): o floci nao expoe registry de blobs; a imagem local ja esta no daemon."
      fi
    done
  fi
done

echo "Deploy concluido! URLs de invocacao:"
terraform output
