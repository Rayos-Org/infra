# How `infra` Wires with Other Repos

The `infra` repo has no runtime code and no npm/cargo dependencies on other repos.
It is a **pure configuration and tooling provider** — every other repo depends on it,
but `infra` depends on nothing.

---

## Dependency Graph

```
                         ┌──────────────────────────────┐
                         │           infra               │
                         │  (CI/CD, Docker, Env Config)  │
                         └──────────────┬───────────────┘
                                        │  provides workflows, env templates
                    ┌───────────────────┼──────────────────────┐
                    ▼                   ▼                        ▼
         ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
         │ wallet-contracts  │  │   wallet-sdk      │  │  relay-backend   │
         │  (Rust/Soroban)  │  │  (TypeScript npm) │  │  (NestJS/Render) │
         └──────────────────┘  └──────────────────┘  └──────────────────┘
                    ▼                   ▼                        ▼
         ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
         │  web-dashboard   │  │   mobile-app      │  │   demo-app       │
         │  (Next.js/Vercel)│  │  (Expo/EAS)       │  │ (Next.js/Vercel) │
         └──────────────────┘  └──────────────────┘  └──────────────────┘
```

---

## Per-Repo Wiring

### `wallet-contracts`

**What it uses from `infra`:**
- `workflows/rust-ci.yml` — Rust formatting, linting, tests, security audit, WASM size check

**How to wire (add to `wallet-contracts/.github/workflows/ci.yml`):**
```yaml
jobs:
  ci:
    uses: Rayos-Org/infra/.github/workflows/rust-ci.yml@main
```

---

### `wallet-sdk`

**What it uses from `infra`:**
- `workflows/node-ci.yml` — lint, typecheck, test, build, audit

**How to wire:**
```yaml
jobs:
  ci:
    uses: Rayos-Org/infra/.github/workflows/node-ci.yml@main
```

---

### `relay-backend`

**What it uses from `infra`:**
- `workflows/node-ci.yml` — CI on every PR
- `workflows/deploy.yml` — deploy to Render on merge to `main`
- `environments/testnet-dev.env.example` — template for local `.env`

**How to wire CI:**
```yaml
jobs:
  ci:
    uses: Rayos-Org/infra/.github/workflows/node-ci.yml@main

  deploy:
    needs: ci
    uses: Rayos-Org/infra/.github/workflows/deploy.yml@main
    with:
      environment: testnet-dev
      service: relay-backend
    secrets:
      RENDER_DEPLOY_HOOK: ${{ secrets.RENDER_DEPLOY_HOOK }}
```

---

### `web-dashboard`

**What it uses from `infra`:**
- `workflows/node-ci.yml` — CI on every PR
- `workflows/deploy.yml` — deploy to Vercel on merge to `main`

**How to wire:**
```yaml
jobs:
  ci:
    uses: Rayos-Org/infra/.github/workflows/node-ci.yml@main

  deploy:
    needs: ci
    uses: Rayos-Org/infra/.github/workflows/deploy.yml@main
    with:
      environment: testnet-dev
      service: web-dashboard
    secrets:
      VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
      VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
      VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

---

### `mobile-app`

**What it uses from `infra`:**
- `workflows/expo-build.yml` — EAS build trigger on PR

**How to wire:**
```yaml
jobs:
  preview-build:
    uses: Rayos-Org/infra/.github/workflows/expo-build.yml@main
    with:
      profile: preview
    secrets:
      EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
```

---

### `demo-app`

**What it uses from `infra`:**
- `workflows/node-ci.yml` — CI on every PR
- `workflows/deploy.yml` — deploy to Vercel (pinned to a stable tag, not `main`)

---

## Secrets Required Per Repo

Each consuming repo must have these secrets set in its GitHub repository settings:

| Secret | Required by |
|---|---|
| `RENDER_DEPLOY_HOOK` | `relay-backend` |
| `VERCEL_TOKEN` | `web-dashboard`, `demo-app` |
| `VERCEL_ORG_ID` | `web-dashboard`, `demo-app` |
| `VERCEL_PROJECT_ID` | `web-dashboard`, `demo-app` |
| `EXPO_TOKEN` | `mobile-app` |
