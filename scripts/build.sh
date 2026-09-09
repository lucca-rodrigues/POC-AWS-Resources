#!/usr/bin/env bash
# Builda todas as functions do monorepo (functions/<nome>).
# Suporta subpastas: functions/crud-node/create, read, update, delete.
# A function kafka usa lib interna (GitHub Packages) — passa o ~/.npmrc via secret.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

build_function() {
  local dir="$1"
  local name="$2"
  echo "== Build: $name =="
  if [ "$name" = "kafka" ] && [ -f "$HOME/.npmrc" ]; then
    docker build --secret id=npmrc,src="$HOME/.npmrc" -t "localhost:4566/futurosign-$name:latest" "$dir"
  else
    docker build -t "localhost:4566/futurosign-$name:latest" "$dir"
  fi
}

for function_dir in "$ROOT_DIR"/functions/*/; do
  name="$(basename "$function_dir")"
  if [ -f "$function_dir/Dockerfile" ]; then
    build_function "$function_dir" "$name"
  else
    # Pasta com subfunctions (ex.: crud-node/create, read, ...)
    for sub_dir in "$function_dir"*/; do
      sub_name="$(basename "$sub_dir")"
      build_function "$sub_dir" "$name-$sub_name"
    done
  fi
done
