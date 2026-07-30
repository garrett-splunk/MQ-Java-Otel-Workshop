# syntax=docker/dockerfile:1
# OpenTelemetry Java Contrib ibm-mq-metrics → OTLP (Splunk Observability Cloud lab track).
ARG OTEL_JAVA_CONTRIB_REF=v1.59.0

FROM eclipse-temurin:11-jdk-jammy AS builder

ARG OTEL_JAVA_CONTRIB_REF
RUN apt-get update && apt-get install -y --no-install-recommends git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${OTEL_JAVA_CONTRIB_REF}" \
  https://github.com/open-telemetry/opentelemetry-java-contrib.git

WORKDIR /src/opentelemetry-java-contrib
RUN ./gradlew :ibm-mq-metrics:shadowJar --no-daemon -x test -x integrationTest

RUN mkdir -p /out \
  && cp ibm-mq-metrics/build/libs/opentelemetry-ibm-mq-monitoring-*-all.jar /out/ibm-mq-metrics.jar \
  && ALLCLIENT="$(find /root/.gradle/caches -name 'com.ibm.mq.allclient-*.jar' -type f | head -1)" \
  && test -n "$ALLCLIENT" \
  && cp "$ALLCLIENT" /out/com.ibm.mq.allclient.jar

FROM eclipse-temurin:11-jre-jammy AS runtime

RUN useradd --system --home /opt/ibm-mq-metrics --shell /usr/sbin/nologin mqmetrics

WORKDIR /opt/ibm-mq-metrics
COPY --from=builder /out/ibm-mq-metrics.jar /opt/ibm-mq-metrics/ibm-mq-metrics.jar
COPY --from=builder /out/com.ibm.mq.allclient.jar /opt/ibm-mq-metrics/com.ibm.mq.allclient.jar
COPY config.lab.yml /opt/ibm-mq-metrics/config.lab.yml
COPY entrypoint.sh /opt/ibm-mq-metrics/entrypoint.sh

RUN chmod 755 /opt/ibm-mq-metrics/entrypoint.sh \
  && chown -R mqmetrics:mqmetrics /opt/ibm-mq-metrics

USER mqmetrics
ENTRYPOINT ["/opt/ibm-mq-metrics/entrypoint.sh"]
