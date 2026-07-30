# IBM MQ → Splunk Observability Cloud (Java Contrib track)

Guided workshop for exporting IBM MQ metrics with [OpenTelemetry Java Contrib `ibm-mq-metrics`](https://github.com/open-telemetry/opentelemetry-java-contrib/tree/main/ibm-mq-metrics) and viewing them in Splunk Observability Cloud.

## Live workshop site

**https://garrett-splunk.github.io/MQ-Java-Otel-Workshop/**

## Lab stack (Docker Compose)

This site documents the Java Contrib exporter track. The runnable lab stack lives in the main repo:

**https://github.com/garrett-splunk/MQ-O11y-Workshop**

Clone that repo, complete Steps 1–6 of the [main workshop](https://garrett-splunk.github.io/MQ-O11y-Workshop/), then follow this site to start the `ibm-mq-java-metrics` sidecar:

```bash
docker compose --profile java-contrib build ibm-mq-java-metrics
docker compose --profile java-contrib up -d ibm-mq-java-metrics
```

Search Splunk Observability Cloud Metric Explorer for `ibm.mq.*` (not `ibmmq.*`).

## Related

| Resource | URL |
|----------|-----|
| Main lab (`mq_otel` track) | https://garrett-splunk.github.io/MQ-O11y-Workshop/ |
| Java Contrib upstream | https://github.com/open-telemetry/opentelemetry-java-contrib/tree/main/ibm-mq-metrics |

## Deploy this site

Pushes to `main` that touch `workshop-site/` run `.github/workflows/pages.yml`, which publishes to the `gh-pages` branch. In repo **Settings → Pages**, set source to **Deploy from a branch**, branch **`gh-pages`**, folder **`/ (root)`**.
