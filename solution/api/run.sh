#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
set -a
source api/.env
set +a
exec python3 -m uvicorn api.app:app --host 127.0.0.1 --port "${API_PORT:-8004}"
