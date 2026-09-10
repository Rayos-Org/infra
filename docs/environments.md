# Environment Strategy

TeamRayos uses a four-tier environment model. Every deployable repo follows this identical promotion path — no exceptions.

---

## The Four Environments

| Environment | Stellar Network | Purpose | How to Deploy |
|---|---|---|---|
| `local` | Stellar Testnet (public RPC) | Individual developer machines | Run `bash scripts/bootstrap-local-dev.sh` |
| `testnet-dev` | Stellar Testnet | Shared integration — runs latest `main` | Automatic on every merge to `main` |
| `testnet-staging` | Stellar Testnet | Stable pre-release, mirrors intended mainnet config | Manual promotion from `testnet-dev` after a soak period |
| `mainnet` | Stellar Mainnet | Production | Manual, requires `audit-passed` label on the PR |

> **Rule:** No repo can deploy to `mainnet` without passing through `testnet-staging` first.
> This is enforced in `workflows/deploy.yml`, not just by convention.

---

## Environment Templates

Each environment has a corresponding template file in `environments/`:

| File | Use |
|---|---|
| [`testnet-dev.env.example`](../environments/testnet-dev.env.example) | Pre-filled with local Docker + testnet contract addresses. Copy to `.env` in each app repo to start immediately. |
| [`testnet-staging.env.example`](../environments/testnet-staging.env.example) | Points to hosted Neon + Upstash endpoints. Fill in API keys via the platform secrets manager. |
| [`mainnet.env.example`](../environments/mainnet.env.example) | Template only — **all values are intentionally blank**. Populated via Render dashboard or Doppler. |

> **Never commit a real `.env` file.** The `.gitignore` in this repo blocks it.
> Always use the platform's secrets manager for real credentials.

---

## Secrets Management Per Environment

### `local`
Secrets live in a local `.env` file in each app repo. The `.gitignore` in every repo blocks this file from being committed.

### `testnet-dev` and `testnet-staging`
Secrets are set directly in the **Render dashboard** (for relay-backend) or **Vercel dashboard** (for web-dashboard, demo-app). They are never committed to source control.

### `mainnet`
Same as staging, but access to the Render/Vercel production environment should be restricted to a small set of administrators. Rotate credentials on a quarterly schedule using [`scripts/rotate-secrets.sh`](../scripts/rotate-secrets.sh).

---

## Adding a New Environment Variable

1. Add it to **all three** `environments/*.env.example` files with a clear comment explaining what it is and where to get it.
2. Update the Render/Vercel dashboard for each hosted environment.
3. Update [`docs/environments.md`](./environments.md) if the variable is significant.
4. Never add a real value to an `.env.example` file — only placeholders.
