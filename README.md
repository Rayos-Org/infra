<div align="center">

# TeamRayos — `infra`

**Centralized CI/CD pipelines, local development environments, and configuration templates for the entire TeamRayos organization.**

[![CI](https://github.com/Rayos-Org/infra/actions/workflows/ci.yml/badge.svg)](https://github.com/Rayos-Org/infra/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](./LICENSE)
[![Stellar Testnet](https://img.shields.io/badge/Stellar-Testnet-7B2FBE?logo=stellar)](https://developers.stellar.org)
[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![Docker](https://img.shields.io/badge/Local_Dev-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com)
[![Postgres](https://img.shields.io/badge/Database-Postgres_16-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Redis](https://img.shields.io/badge/Cache-Redis_7-DC382D?logo=redis&logoColor=white)](https://redis.io)
[![OpenTelemetry](https://img.shields.io/badge/Observability-OpenTelemetry-F5A800?logo=opentelemetry&logoColor=white)](https://opentelemetry.io)

</div>

---

## What is this repo?

`infra` is the single source of truth for **how the TeamRayos organization builds, tests, and deploys every service**. It contains no application code — only:

- **Reusable GitHub Actions workflows** referenced by `wallet-contracts`, `wallet-sdk`, `relay-backend`, `web-dashboard`, `mobile-app`, and `demo-app`
- **Docker Compose files** for spinning up a local Postgres + Redis stack with one command
- **Environment templates** pre-filled with testnet configuration
- **Scripts** for bootstrapping local dev and rotating secrets
- **Observability config** for OpenTelemetry → Grafana Cloud

> **New contributors:** Run `bash scripts/bootstrap-local-dev.sh` to get the full local stack running in under 2 minutes.

---

## Repository Structure

```
infra/
├── .github/
│   └── workflows/
│       ├── ci.yml                    ← infra's own self-validation CI
│       ├── rust-ci.yml               ← reusable: for wallet-contracts
│       ├── node-ci.yml               ← reusable: for wallet-sdk, relay-backend, web-dashboard
│       ├── expo-build.yml            ← reusable: for mobile-app
│       └── deploy.yml                ← reusable: parameterized deploy for all services
├── workflows/                        ← canonical source (mirrored to .github/workflows/)
├── docker/
│   ├── docker-compose.local.yml      ← Postgres 16 + Redis 7 for local dev
│   └── docker-compose.ci.yml         ← slim ephemeral version for CI E2E jobs
├── environments/
│   ├── testnet-dev.env.example       ← pre-filled testnet config (copy to .env)
│   ├── testnet-staging.env.example   ← staging config template
│   └── mainnet.env.example           ← mainnet template (values via secrets manager only)
├── observability/
│   └── otel-collector-config.yaml    ← OTel Collector → Grafana Cloud
├── scripts/
│   ├── bootstrap-local-dev.sh        ← ONE command → full running local stack
│   └── rotate-secrets.sh             ← secrets rotation runbook
└── docs/                             ← contributor documentation
    ├── local-development.md
    ├── workflows.md
    ├── environments.md
    ├── secrets-and-security.md
    ├── observability.md
    └── repo-wiring.md
```

---

## Quick Start

**Prerequisites:** Docker, Node.js ≥ 22, pnpm ≥ 9, [Stellar CLI](https://developers.stellar.org/docs/tools/stellar-cli)

```bash
git clone https://github.com/Rayos-Org/infra.git
cd infra
bash scripts/bootstrap-local-dev.sh
```

After ~60 seconds you'll see:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅  Local dev stack is running

  Postgres    →  postgresql://postgres:password@localhost:5432/relay_dev
  Redis       →  redis://localhost:6379
  Soroban RPC →  https://soroban-testnet.stellar.org (testnet)

  Factory Contract  →  CCCAMWJOF7IYTVCU7SR6HFTNH5XRMDMWPYN464NY5BCKUPMUM64RZ5CH
  Policy Contract   →  CCDM3O2SXX3E24MCWLRK5YBVQHJCA4OQKJFF6KWCK6FHZS65DGMT6DOY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

See **[docs/local-development.md](./docs/local-development.md)** for next steps.

---

## Environment Strategy

| Environment | Network | Purpose | Promotion |
|---|---|---|---|
| `local` | Stellar Testnet | Your machine | `bootstrap-local-dev.sh` |
| `testnet-dev` | Stellar Testnet | Shared integration | Auto on merge to `main` |
| `testnet-staging` | Stellar Testnet | Stable pre-release | Manual promotion |
| `mainnet` | Stellar Mainnet | Production | Manual + `audit-passed` label |

> No repo can deploy to `mainnet` without passing through `testnet-staging` first.
> This is enforced in `workflows/deploy.yml`, not just by convention.

---

## How Other Repos Use This

Every other TeamRayos repo calls these workflows without duplicating pipeline logic:

```yaml
# Example: wallet-contracts/.github/workflows/ci.yml
jobs:
  ci:
    uses: Rayos-Org/infra/.github/workflows/rust-ci.yml@main

# Example: relay-backend/.github/workflows/ci.yml
jobs:
  ci:
    uses: Rayos-Org/infra/.github/workflows/node-ci.yml@main
```

See **[docs/repo-wiring.md](./docs/repo-wiring.md)** for the complete wiring guide for all 6 repos.

---

## How the Stack Fits Together

```
                    ┌────────────────────────────────────┐
                    │              infra                  │
                    │  CI/CD · Docker · Env · Scripts     │
                    └────────────────┬───────────────────┘
                                     │ provides to all repos
          ┌──────────────────────────┼──────────────────────────┐
          ▼                          ▼                           ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│ wallet-contracts  │      │   wallet-sdk      │      │  relay-backend   │
│  Rust · Soroban  │      │  TypeScript npm   │      │  NestJS · Render │
│  (live testnet)  │      │  (published npm)  │      │  (live on Render)│
└──────────────────┘      └────────┬─────────┘      └──────────────────┘
                                   │ consumed by
               ┌───────────────────┼───────────────────┐
               ▼                   ▼                    ▼
    ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
    │  web-dashboard   │  │   mobile-app      │  │   demo-app       │
    │  Next.js·Vercel  │  │  Expo · EAS       │  │ Next.js · Vercel │
    └──────────────────┘  └──────────────────┘  └──────────────────┘
```

---

## Deployed Testnet Contracts

| Contract | Address |
|---|---|
| Factory | `CCCAMWJOF7IYTVCU7SR6HFTNH5XRMDMWPYN464NY5BCKUPMUM64RZ5CH` |
| Policy | `CCDM3O2SXX3E24MCWLRK5YBVQHJCA4OQKJFF6KWCK6FHZS65DGMT6DOY` |
| Wallet WASM Hash | `8c2e77ad251a8e32590280c95627fd24864f1ff1917d781e44510f450445d7c6` |

Live relay-backend API: **https://rayos-relay-backend.onrender.com/api**  
Swagger Docs: **https://rayos-relay-backend.onrender.com/api/docs**

---

## Documentation

| Document | Description |
|---|---|
| [Local Development](./docs/local-development.md) | Full setup guide — prerequisites, bootstrap script, troubleshooting |
| [CI/CD Workflows](./docs/workflows.md) | How each reusable workflow works and what it checks |
| [Environment Strategy](./docs/environments.md) | The four-tier environment model and promotion rules |
| [Secrets & Security](./docs/secrets-and-security.md) | How credentials are managed, rotation runbook, incident response |
| [Observability](./docs/observability.md) | OTel + Grafana Cloud setup, key metrics, uptime checks |
| [Repo Wiring](./docs/repo-wiring.md) | Exact YAML snippets for wiring each consuming repo |
| [Contributing](./CONTRIBUTING.md) | How to propose changes to this repo |
| [Security Policy](./SECURITY.md) | How to report a vulnerability |

---

## Tech Stack

| Layer | Tool | Why |
|---|---|---|
| CI/CD | GitHub Actions (reusable workflows) | Free for public repos, zero vendor lock-in |
| Local dev | Docker + docker-compose | Reproducible environments across machines |
| Database | Neon (serverless Postgres 16) | Open-source Postgres core, branch-per-environment |
| Cache / Queue | Upstash Redis 7 | Serverless Redis, pairs well with Render |
| Observability | OpenTelemetry + Grafana Cloud | Fully open-source pipeline |
| Backend hosting | Render | Free tier, persistent workers for BullMQ |
| Frontend hosting | Vercel | PR preview deployments, zero-config Next.js |
| Blockchain | Stellar Testnet → Mainnet | Open-source Soroban RPC, no proprietary API |

> Every tool in this stack is open-source and self-hostable. No closed SaaS in the critical path.

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

> ⚠️ Changes to this repo affect every other TeamRayos repository. A broken reusable workflow breaks everyone's CI. Please test locally before opening a PR.

---

## License

[Apache 2.0](./LICENSE)
