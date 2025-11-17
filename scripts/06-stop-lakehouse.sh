#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/opt/lakehouse_repo"

if [ ! -d "$ROOT_DIR" ]; then
  echo "Lakehouse repo not found at $ROOT_DIR"
  exit 1
fi

cd "$ROOT_DIR"

if [ ! -x "./manage-lakehouse.sh" ]; then
  chmod +x ./manage-lakehouse.sh || true
fi

echo "Stopping Lakehouse stack..."
./manage-lakehouse.sh stop

echo "Lakehouse stopped."

