#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
{
 printf '%s\n' 'BEGIN;' "SELECT pg_advisory_xact_lock(54332810);" "SET LOCAL lock_timeout='10s';" "SET LOCAL statement_timeout='120s';"
 printf '%s\n' 'LOCK TABLE raw.orders,raw.order_items,raw.order_payments,raw.order_reviews,raw.customers,raw.products,raw.sellers,raw.product_category_translation IN SHARE MODE;'
 cat model/*.sql model/verify/01_checks.sql
 printf '%s\n' 'COMMIT;'
} | docker compose exec -T postgres psql -X -v ON_ERROR_STOP=1 -U hack -d marketplace
