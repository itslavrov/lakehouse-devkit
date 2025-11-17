#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/opt/lakehouse_repo"

if [ ! -d "$ROOT_DIR" ]; then
  echo "Repo not found at $ROOT_DIR"
  exit 1
fi

cd "$ROOT_DIR"

echo "Docker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "minio|nessie|trino|airflow|postgres|redis" || true

echo
echo "Lake compose:"
docker compose -f docker-compose-lake.yaml ps || true

echo
echo "Trino compose:"
docker compose -f docker-compose-trino.yaml ps || true

echo
echo "Airflow compose:"
docker compose -f docker-compose-airflow.yaml ps || true

