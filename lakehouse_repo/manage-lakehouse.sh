#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPTS_TO_CHECK=(
  "trino_config/create-password-db.sh"
  "trino_config/generate-configs.sh"
)

for script in "${SCRIPTS_TO_CHECK[@]}"; do
  SCRIPT_PATH="${SCRIPT_DIR}/${script}"
  if [ -f "$SCRIPT_PATH" ] && [ ! -x "$SCRIPT_PATH" ]; then
    chmod +x "$SCRIPT_PATH" || true
  fi
done

load_env() {
  ENV_FILE="${SCRIPT_DIR}/.env"

  if [ -f "$ENV_FILE" ]; then
    . "$ENV_FILE"
  fi

  MINIO_ROOT_USER="${MINIO_ROOT_USER:-minioadmin}"
  MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-minioadmin}"

  AIRFLOW_USERNAME="${AIRFLOW_USERNAME:-airflow}"
  AIRFLOW_PASSWORD="${AIRFLOW_PASSWORD:-airflow}"

  TRINO_USERNAME="${TRINO_USERNAME:-trino}"
  TRINO_PASSWORD="${TRINO_PASSWORD:-trino}"
  TRINO_INTERNAL_SECRET="${TRINO_INTERNAL_SECRET:-}"

  TRINO_PORT="${TRINO_PORT:-8080}"
  AIRFLOW_API_PORT="${AIRFLOW_API_PORT:-8081}"
}

start_services() {
  echo "Starting Local Lakehouse services..."

  cd "$SCRIPT_DIR"

  echo "Generating Trino configuration files..."
  if [ -f "./trino_config/generate-configs.sh" ]; then
    ./trino_config/generate-configs.sh
  else
    echo "Warning: generate-configs.sh not found, using existing configs"
  fi

  echo "Creating Trino password file..."
  ./trino_config/create-password-db.sh

  echo "Starting data lake services (MinIO + Nessie)..."
  docker compose -f docker-compose-lake.yaml up -d
  sleep 5

  echo "Starting Trino query engine..."
  docker compose -f docker-compose-trino.yaml up -d
  
  echo "Waiting for Trino to start (45 seconds)..."
  sleep 45

  echo "Initializing Trino schemas..."
  load_env
  if docker ps | grep -q trino-coordinator; then
    docker exec trino-coordinator trino \
      --server http://localhost:8080 \
      --user "$TRINO_USERNAME" \
      --password "$TRINO_PASSWORD" \
      --file /etc/trino/init.sql
    echo "Trino schemas initialized successfully."
  else
    echo "Warning: Trino coordinator not running, skipping schema initialization"
  fi
  
  echo "Starting Airflow orchestration services..."
  docker compose -f docker-compose-airflow.yaml up -d
  sleep 5

  load_env

  echo "All services started successfully."
}

load_dbt_seed_data() {
  echo "Loading CSV seed data via dbt..."
  
  load_env
  export TRINO_USERNAME="$TRINO_USERNAME"
  export TRINO_PASSWORD="$TRINO_PASSWORD"
  
  if command -v dbt >/dev/null 2>&1; then
    dbt seed --project-dir ./dags/dbt_trino --profiles-dir ./dags/dbt_trino
    echo "CSV files loaded to landing schema via dbt."
  else
    echo "Error: dbt not found in PATH"
    exit 1
  fi
  echo
}

stop_services() {
  echo "Stopping Local Lakehouse services..."

  cd "$SCRIPT_DIR"

  echo "Stopping Airflow services..."
  docker compose -f docker-compose-airflow.yaml down -v

  echo "Stopping Trino services..."
  docker compose -f docker-compose-trino.yaml down -v

  echo "Stopping data lake services..."
  docker compose -f docker-compose-lake.yaml down -v

  echo "All services stopped and volumes cleaned up."
  echo
}

show_info() {
  load_env
  
  HOST_IP="$(hostname -I | awk '{print $1}')"
  if [ -z "$HOST_IP" ] || [[ "$HOST_IP" =~ ^127\. ]] || [[ "$HOST_IP" =~ ^172\.17\. ]]; then
    HOST_IP="localhost"
  fi
  
  echo "Lakehouse Services Information:"
  echo "==============================="
  echo
  echo "MinIO Console:"
  echo "  Network:    http://${HOST_IP}:9001"
  echo "  User:       ${MINIO_ROOT_USER}"
  echo "  Password:   ${MINIO_ROOT_PASSWORD}"
  echo
  echo "Trino Web UI:"
  echo "  Network:    http://${HOST_IP}:${TRINO_PORT}"
  echo "  User:       ${TRINO_USERNAME}"
  echo "  Password:   ${TRINO_PASSWORD}"
  echo "  Note:       Password authentication enabled"
  echo
  echo "Airflow Web UI:"
  echo "  Network:    http://${HOST_IP}:${AIRFLOW_API_PORT}"
  echo "  User:       ${AIRFLOW_USERNAME}"
  echo "  Password:   ${AIRFLOW_PASSWORD}"
  echo
  echo "Nessie API:"
  echo "  URL:        http://${HOST_IP}:19120"
  echo "  User:       ${NESSIE_USERNAME:-nessie}"
  echo "  Password:   ${NESSIE_PASSWORD}"
  echo
}

case "${1:-help}" in
  start)
    start_services
    ;;
  stop)
    stop_services
    ;;
  seed)
    load_dbt_seed_data
    ;;
  info)
    show_info
    ;;
  *)
    ;;
esac