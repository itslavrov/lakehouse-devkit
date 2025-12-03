#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$ROOT_DIR/.env" ]; then
    source "$ROOT_DIR/.env"
else
    echo "ERROR: .env file not found"
    exit 1
fi

MINIO_USER="${MINIO_ROOT_USER:-minioadmin}"
MINIO_PASS="${MINIO_ROOT_PASSWORD}"

cat > "$SCRIPT_DIR/catalog/iceberg.properties" << FILEEOF
connector.name=iceberg
iceberg.catalog.type=nessie
iceberg.nessie-catalog.uri=http://nessie-catalog:19120/api/v2
iceberg.nessie-catalog.ref=main
iceberg.nessie-catalog.default-warehouse-dir=s3://local-lakehouse
fs.native-s3.enabled=true
s3.endpoint=http://minio:9000
s3.region=us-east-1
s3.path-style-access=true
s3.aws-access-key=$MINIO_USER
s3.aws-secret-key=$MINIO_PASS
FILEEOF

echo "Generated iceberg.properties with MinIO credentials"