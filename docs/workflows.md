# CI/CD Workflows

All reusable GitHub Actions workflows live in this repo and are called by every other TeamRayos repository. This prevents copy-pasting pipeline logic across 7+ repos.

---

## How Consuming Repos Use These Workflows

A consuming repo references a workflow like this:

```yaml
# In wallet-contracts/.github/workflows/ci.yml
jobs:
  ci:
    uses: Rayos-Org/infra/.github/workflows/rust-ci.yml@main
```

No duplication. If we fix a bug in `rust-ci.yml`, all consuming repos get the fix automatically on their next run.

---

## Workflow Reference

### `rust-ci.yml` — Used by `wallet-contracts`

| Step | What it does |
|---|---|
| `cargo fmt --check` | Enforces consistent Rust formatting |
| `cargo clippy -- -D warnings` | Linting — warnings are errors in CI |
| `cargo test --all` | Runs all unit and integration tests |
| `cargo audit` | Scans for known CVEs in dependencies |
| WASM size check | Fails if any compiled `.wasm` exceeds 100 KB |

**Inputs:**
- `working-directory` (optional, default: `.`)

---

### `node-ci.yml` — Used by `wallet-sdk`, `relay-backend`, `web-dashboard`, `demo-app`

| Step | What it does |
|---|---|
| `pnpm install --frozen-lockfile` | Reproducible install, fails if lockfile is out of sync |
| `pnpm lint` | ESLint check |
| `pnpm typecheck` | TypeScript type-check (`tsc --noEmit`) |
| `pnpm test` | Runs Vitest or Jest test suite |
| `pnpm build` | Production build |
| `pnpm audit` | Scans for known CVEs in npm dependencies |

**Inputs:**
- `working-directory` (optional, default: `.`)
- `node-version` (optional, default: `22`)
- `package-manager` (optional, default: `pnpm`)

---

### `expo-build.yml` — Used by `mobile-app`

| Step | What it does |
|---|---|
| EAS Build | Triggers an Expo Application Services build |

**Inputs:**
- `profile` (required) — `preview` or `production`

**Secrets required in the consuming repo:**
- `EXPO_TOKEN`

---

### `deploy.yml` — Used by all deployable repos

Handles automated deployment to Render (relay-backend) or Vercel (web-dashboard, demo-app).

**Inputs:**
- `environment` (required) — `testnet-dev` | `testnet-staging` | `mainnet`
- `service` (required) — `relay-backend` | `web-dashboard` | `demo-app`

**Secrets required in the consuming repo:**
- `RENDER_DEPLOY_HOOK` (for relay-backend)
- `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` (for Vercel deploys)

#### Mainnet Gate

The `mainnet` environment is protected. The workflow will **refuse to deploy** unless the triggering pull request has the `audit-passed` label applied by a repository admin.

```
testnet-dev  → auto on merge to main
testnet-staging → manual promotion only
mainnet         → manual + 'audit-passed' label required
```

---

## Infra's Own CI (`ci.yml`)

The `infra` repo validates itself:
- YAML lint on all workflow and Docker files
- ShellCheck on all `.sh` scripts
- `docker compose config` syntax validation on both compose files

This runs on every push and pull request to `main`.
