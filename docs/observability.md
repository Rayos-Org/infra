# Observability

All telemetry from the TeamRayos stack flows through an OpenTelemetry Collector and is visualised in Grafana Cloud.

---

## Architecture

```
relay-backend  ──OTLP──►  OTel Collector  ──OTLP/HTTP──►  Grafana Cloud
(structured logs,           (batch, tag,                   (dashboards, alerts)
 traces, metrics)           resource-enrich)
```

---

## Setting Up Grafana Cloud (Free Tier)

1. Sign up at [grafana.com](https://grafana.com/products/cloud/) (free tier is sufficient)
2. Navigate to **Connections → Add new connection → OpenTelemetry**
3. Follow the setup wizard to get:
   - `GRAFANA_OTLP_ENDPOINT` (e.g., `https://otlp-gateway-prod-us-central-0.grafana.net/otlp`)
   - `GRAFANA_OTLP_AUTH` (base64 encoded `instanceId:apiToken`)
4. Set both as environment variables wherever the OTel Collector runs

---

## Collector Configuration

The collector config lives at [`observability/otel-collector-config.yaml`](../observability/otel-collector-config.yaml).

It:
- Accepts OTLP signals over gRPC (`4317`) and HTTP (`4318`)
- Batches signals for efficiency
- Injects `service.namespace=rayos` and `deployment.environment` resource attributes
- Exports to Grafana Cloud

---

## Key Metrics to Watch

### relay-backend

| Metric | Why it matters |
|---|---|
| `POST /api/relay/submit` latency | Highest-traffic, most latency-sensitive endpoint |
| `POST /api/relay/submit` error rate | A spike here means fee-bump failures |
| BullMQ queue depth | Stalled recovery jobs surface here |
| DB query latency | Neon cold-start latency will show up here |

### Uptime

Set up uptime checks on:
- `https://rayos-relay-backend.onrender.com/api` — relay health
- Your web-dashboard production URL
- Your demo-app production URL

Grafana Cloud includes a free synthetic monitoring feature. UptimeRobot's free tier is also a good alternative.

---

## Structured Logging in relay-backend

`relay-backend` emits structured JSON logs. Every log line includes:
- `level` — `info`, `warn`, `error`
- `context` — the NestJS module name
- `message`
- Any relevant request/response metadata

These are automatically ingested by the OTel Collector's log pipeline.

---

## Contract Invariant Monitoring

Before mainnet, add a scheduled BullMQ job in `relay-backend` that runs every 10 minutes and:
- Reads on-chain signer state for known wallets
- Alerts via Discord webhook if unexpected signer rotation or spend-limit bypass is detected

This is cheap insurance. Build it before mainnet funds are at risk, not after.
