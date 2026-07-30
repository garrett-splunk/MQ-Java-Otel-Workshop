#!/usr/bin/env bash
# Send test orders to order-producer (no Node/npm required).
set -euo pipefail

BASE_URL="${PRODUCER_URL:-http://localhost:8080}"
COUNT="${1:-20}"
DELAY_MS="${2:-500}"

echo "Sending ${COUNT} orders to ${BASE_URL} (${DELAY_MS}ms apart)"
for ((i = 0; i < COUNT; i++)); do
  correlation_id="load-$(date +%s)-${i}"
  sku=$((100 + i % 5))
  qty=$((1 + i % 3))
  response="$(curl -sf -w '\n%{http_code}' -X POST "${BASE_URL}/orders" \
    -H "Content-Type: application/json" \
    -H "X-Correlation-Id: ${correlation_id}" \
    -d "{\"productId\":\"SKU-${sku}\",\"quantity\":${qty}}")" || {
    echo "FAIL request ${i} (${correlation_id})"
    exit 1
  }
  body="$(printf '%s' "$response" | sed '$d')"
  status="$(printf '%s' "$response" | tail -1)"
  echo "${status} ${correlation_id} ${body:0:120}"
  if [ "$DELAY_MS" -gt 0 ] && [ "$i" -lt $((COUNT - 1)) ]; then
    python3 -c "import time; time.sleep(${DELAY_MS} / 1000)"
  fi
done
