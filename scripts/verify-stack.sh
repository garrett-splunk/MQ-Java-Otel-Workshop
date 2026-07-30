#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== IBM MQ Java Contrib O11y lab stack verification =="

failures=0
check() {
  local name="$1"
  shift
  if "$@"; then
    echo "OK  $name"
  else
    echo "FAIL $name"
    failures=$((failures + 1))
  fi
}

check "order-producer health" curl -sf "http://localhost:8080/health" | grep -q order-producer
check "order-consumer health" curl -sf "http://localhost:8081/health" | grep -q order-consumer
check "inventory-service health" curl -sf "http://localhost:8082/health" | grep -q inventory-service
check "otel-collector health" curl -sf "http://localhost:13133/"
check "workshop site" curl -sf "http://localhost:8091/" | grep -qi "IBM MQ"
check "ibm-mq-java-metrics running" docker compose ps --status running ibm-mq-java-metrics 2>/dev/null | grep -q ibm-mq-java-metrics

echo "== Sample order =="
RESP=$(curl -sf -X POST "http://localhost:8080/orders" \
  -H "Content-Type: application/json" \
  -H "X-Correlation-Id: verify-$(date +%s)" \
  -d '{"productId":"SKU-100","quantity":2}')
echo "$RESP" | grep -q accepted && echo "OK  POST /orders" || { echo "FAIL POST /orders: $RESP"; failures=$((failures + 1)); }

if [ "$failures" -gt 0 ]; then
  echo "Verification finished with $failures failure(s)."
  exit 1
fi

echo "All checks passed."
