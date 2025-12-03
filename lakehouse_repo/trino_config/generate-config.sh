#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$ROOT_DIR/.env" ]; then
    source "$ROOT_DIR/.env"
fi

TRINO_INTERNAL_SECRET="${TRINO_INTERNAL_SECRET:-trino-internal-secret-$(date +%s)}"

cat > "$SCRIPT_DIR/coordinator/config.properties" << EOF
coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port=8080
discovery.uri=http://localhost:8080
http-server.authentication.type=PASSWORD
internal-communication.shared-secret=$TRINO_INTERNAL_SECRET
internal-communication.https-required=false
EOF

cat > "$SCRIPT_DIR/worker/config.properties" << EOF
coordinator=false
http-server.http.port=8080
discovery.uri=http://trino-coordinator:8080
http-server.authentication.type=PASSWORD
internal-communication.shared-secret=$TRINO_INTERNAL_SECRET
internal-communication.https-required=false
EOF

echo "Trino configuration files generated with internal secret"