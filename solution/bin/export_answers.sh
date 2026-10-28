#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results/answers
for query in queries/*.sql; do
 docker compose exec -T postgres psql -X -q --csv -v ON_ERROR_STOP=1 -U hack -d marketplace < "$query" > "results/answers/$(basename "$query" .sql).csv"
done
