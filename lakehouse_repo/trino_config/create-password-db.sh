#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$ROOT_DIR/.env" ]; then
    source "$ROOT_DIR/.env"
fi

TRINO_USER="${TRINO_USERNAME:-trino}"
TRINO_PASS="${TRINO_PASSWORD:-trino}"

echo "$TRINO_USER:$TRINO_PASS" > "$SCRIPT_DIR/password.db"
echo "Password file created for user: $TRINO_USER"