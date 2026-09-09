#!/usr/bin/env bash
# Builda todas as functions do monorepo (functions/<nome>).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for function_dir in "$ROOT_DIR"/functions/*/; do
  name="$(basename "$function_dir")"
  echo "== Build: $name =="
  docker build -t "localhost:4566/futurosign-$name:latest" "$function_dir"
done
