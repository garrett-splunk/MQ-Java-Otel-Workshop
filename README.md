# IBM MQ → OpenTelemetry Java Contrib → Splunk Observability Cloud

Hands-on workshop: IBM MQ queue manager, **OpenTelemetry Java Contrib `ibm-mq-metrics`**, instrumented sample apps (APM traces + logs), and OpenTelemetry Collector → Splunk Observability Cloud **Metrics**, **APM**, and **Log Observer**. Sample apps generate message traffic so queue depth and trace volume change.

## Quick start

**Apple Silicon (M1/M2/M3):** IBM MQ and the Java metrics image run under `platform: linux/amd64` in Compose. The Java metrics image downloads prebuilt JARs from Maven Central (about a minute), not a Gradle compile.

```bash
git clone https://github.com/garrett-splunk/MQ-Java-Otel-Workshop.git
cd MQ-Java-Otel-Workshop
cp .env.example .env
cp .env.splunk.example .env.splunk   # add your Splunk ingest token
docker compose up --build -d
bash scripts/verify-stack.sh
```

| URL | Purpose |
|-----|---------|
| https://garrett-splunk.github.io/MQ-Java-Otel-Workshop/ | Guided workshop (GitHub Pages) |
| http://localhost:8091 | Workshop site (local, with stack running) |
| http://localhost:8080 | Order producer API |
| http://localhost:8082 | Inventory service API |
| http://localhost:9443/ibmmq/console | MQ web console (`admin` / password from `.env`) |
| http://localhost:13133 | OTel Collector health |

**Splunk filter:** `deployment.environment:ibm-mq-lab` · MQ metrics: **`ibm.mq`** · APM services: **`order-producer`**, **`inventory-service`**, **`order-consumer`**

App traces are **on by default** (`OTEL_SDK_DISABLED=false` in `.env.example`). Spans include `inventory.check`, `mq.put.order`, `mq.get.order`, and `inventory.fulfill`.

## Application architecture (service map)

The demo simulates an order pipeline with three instrumented Node.js services plus IBM MQ:

```
Client → order-producer → inventory-service (/check)
              ↓
           IBM MQ (ORDER.REQ)
              ↓
         order-consumer → inventory-service (/fulfill)
```

| Step | What happens |
|------|----------------|
| 1 | `POST /orders` hits **order-producer** (`:8080`) with `productId`, `quantity`, and optional `X-Correlation-Id` |
| 2 | Producer calls **inventory-service** `POST /check` — rejects with `409` if stock is insufficient |
| 3 | Producer publishes JSON to MQ queue `ORDER.REQ` (`mq.put.order` span) and returns `202` |
| 4 | **order-consumer** reads the message in the background (`mq.get.order` span) |
| 5 | Consumer calls **inventory-service** `POST /fulfill` to decrement in-memory stock |

**Splunk APM service map edges:** `order-producer` → `inventory-service`, `order-producer` → MQ, MQ → `order-consumer`, `order-consumer` → `inventory-service`.

Producer and consumer traces are **separate trees** (async via MQ); link them with the shared `orderId` / correlation ID in logs and span attributes. Full detail: [workshop site — Architecture](https://garrett-splunk.github.io/MQ-Java-Otel-Workshop/#architecture).

## Send test orders

```bash
curl -X POST http://localhost:8080/orders \
  -H "Content-Type: application/json" \
  -H "X-Correlation-Id: demo-1" \
  -d '{"productId":"SKU-100","quantity":2}'

bash scripts/load-traffic.sh 30 400
```

## Splunk setup

Secrets live only in `.env.splunk` (gitignored). The collector loads them and forwards OTLP metrics to Splunk Observability Cloud. See `.env.splunk.example`.

## Related lab

The [MQ-O11y-Workshop](https://github.com/garrett-splunk/MQ-O11y-Workshop) repo covers the IBM Go **`mq_otel`** exporter track (`ibmmq.*` metrics) with a metrics-first workshop; APM is documented as Phase 2 there. This repo includes **metrics + APM + logs** in the guided steps.

## Teardown

```bash
docker compose down -v
```

## License

IBM MQ container requires `LICENSE=accept` (developer/education use). See [IBM MQ container license](https://github.com/ibm-messaging/mq-container).
