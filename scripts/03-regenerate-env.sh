#!/usr/bin/env bash
set -euo pipefail

REPO="/opt/lakehouse_repo"
ENV_FILE="${REPO}/.env"

if [ ! -d "$REPO" ]; then
  echo "ERROR: Repo not found at $REPO"
  exit 1
fi

cd "$REPO"

echo "Stopping all lakehouse services..."
./manage-lakehouse.sh stop || true

if [ -f "$ENV_FILE" ]; then
  echo "Removing old .env..."
  rm -f "$ENV_FILE"
fi

echo "Generating new .env..."
/opt/scripts/03-generate-env.sh

echo
echo "New .env generated:"
echo "-----------------------------------------"
cat "$ENV_FILE"
echo "-----------------------------------------"

echo "Env regeneration completed. You can now run:"
echo "  /opt/scripts/04-start-lakehouse.sh"
echo

