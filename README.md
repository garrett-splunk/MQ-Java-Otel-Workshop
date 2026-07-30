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
| http://localhost:9443/ibmmq/console | MQ web console (`admin` / password from `.env`) |
| http://localhost:13133 | OTel Collector health |

**Splunk filter:** `deployment.environment:ibm-mq-lab` · MQ metrics: **`ibm.mq`** · APM services: **`order-producer`**, **`order-consumer`**

App traces are **on by default** (`OTEL_SDK_DISABLED=false` in `.env.example`). Spans include `mq.put.order` and `mq.get.order`.

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
