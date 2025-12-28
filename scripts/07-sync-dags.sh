#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/itslavrov/lakehouse-devkit.git"
BRANCH="main"
SPARSE_PATH="lakehouse_repo/dags"

BASE_DIR="${LAKEHOUSE_HOME:-/opt}"
DEFAULT_TARGET_DIR="${BASE_DIR%/}/lakehouse_repo/dags"
TARGET_DIR="${DAGS_DIR:-$DEFAULT_TARGET_DIR}"

echo "Repo:        ${REPO_URL} (branch: ${BRANCH})"
echo "Sparse path:  ${SPARSE_PATH}"
echo "Target dir:   ${TARGET_DIR}"

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is not installed"
  exit 1
fi

mkdir -p "$TARGET_DIR"

WORK_DIR="$(mktemp -d)"
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

echo "Cloning sparse '${SPARSE_PATH}' into temp workdir: ${WORK_DIR}"

git clone --branch "$BRANCH" --depth 1 \
  --filter=blob:none \
  --sparse \
  "$REPO_URL" "$WORK_DIR"

cd "$WORK_DIR"
git sparse-checkout set "$SPARSE_PATH"

SRC_DIR="${WORK_DIR}/${SPARSE_PATH}"

if [ ! -d "$SRC_DIR" ]; then
  echo "ERROR: Source dags directory not found in repo: ${SPARSE_PATH}"
  exit 1
fi

echo "Syncing dags to ${TARGET_DIR} ..."
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "${SRC_DIR%/}/" "${TARGET_DIR%/}/"
else
  rm -rf "${TARGET_DIR%/}"/*
  cp -R "${SRC_DIR%/}/." "${TARGET_DIR%/}/"
fi

echo "Done. Dags are ready at: ${TARGET_DIR}"