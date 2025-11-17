#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/alex-belozersky/local_lakehouse.git"
TARGET_DIR="/opt/lakehouse_repo"

if ! command -v git >/dev/null 2>&1; then
  echo "git is not installed"
  exit 1
fi

if [ -d "$TARGET_DIR/.git" ]; then
  echo "Repo already exists — updating..."
  git -C "$TARGET_DIR" fetch --all --prune
  git -C "$TARGET_DIR" pull --rebase
else
  echo "Cloning repo into $TARGET_DIR..."
  git clone "$REPO_URL" "$TARGET_DIR"
fi

echo "Repo ready at $TARGET_DIR"

