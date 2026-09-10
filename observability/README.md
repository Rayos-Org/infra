# Observability Configuration

This directory contains the configuration for the OpenTelemetry (OTel) Collector used across the TeamRayos organization.

## Setup with Grafana Cloud (Free Tier)

We use Grafana Cloud to ingest traces, metrics, and structured logs.

1. Create a free account at [Grafana Cloud](https://grafana.com/products/cloud/).
2. Navigate to **Connections > Add new connection > OpenTelemetry**.
3. Copy your OTLP Endpoint and generate an API Token.
4. Set the following environment variables wherever the collector runs (e.g., in your Render dashboard for the `relay-backend` or in GitHub Secrets):
   - `GRAFANA_OTLP_ENDPOINT` (e.g., `https://otlp-gateway-prod-us-central-0.grafana.net/otlp`)
   - `GRAFANA_OTLP_AUTH` (this is `base64(instanceId:apiToken)`)

## How it works

The backend applications (like `relay-backend`) emit OTLP signals to `0.0.0.0:4317` (gRPC) or `0.0.0.0:4318` (HTTP). This collector receives them, batches them, injects standard resource attributes (like `deployment.environment`), and securely exports them to Grafana Cloud.

