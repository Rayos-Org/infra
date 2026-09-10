# Secrets & Security

---

## Golden Rules

1. **No secrets ever live in this repo.** This repo contains only templates (`*.env.example`). Real credentials are injected by the platform's secrets manager.
2. **`*.env` is gitignored.** The `.gitignore` in this repo blocks any `*.env` file from being committed. If you accidentally stage one, run `git rm --cached .env`.
3. **Mainnet deployment requires explicit sign-off.** The `deploy.yml` workflow enforces an `audit-passed` label gate before any mainnet deployment. This cannot be bypassed automatically.

---

## Credentials Used Across Environments

| Credential | What it's for | Where to get it | Rotate how often |
|---|---|---|---|
| `DATABASE_URL` | Neon Postgres connection string | Neon dashboard | Quarterly or after exposure |
| `REDIS_URL` | Upstash Redis connection string | Upstash dashboard | Quarterly or after exposure |
| `LAUNCHTUBE_API_KEY` | Fee-bump sponsorship on Stellar | [launchtube.xyz](https://launchtube.xyz) | Quarterly or after exposure |
| `RESEND_API_KEY` | Email notifications for guardian recovery | [resend.com](https://resend.com) | Quarterly or after exposure |
| `RENDER_DEPLOY_HOOK` | Triggers a Render deploy | Render dashboard → Deploy Hook | On personnel change |
| `VERCEL_TOKEN` | Vercel API access | Vercel account settings | On personnel change |
| `EXPO_TOKEN` | EAS build authentication | expo.dev account settings | On personnel change |

---

## Rotating Secrets

Run the rotation runbook:

```bash
bash scripts/rotate-secrets.sh
```

This script does **not** rotate anything automatically — it is a printed checklist of the exact steps to follow for each credential. This is intentional: automated rotation without validation can cause outages.

**After rotating any credential:**
1. Update the value in the platform dashboard (Render / Vercel)
2. Verify the service health endpoint: `GET https://rayos-relay-backend.onrender.com/api`
3. Watch Grafana for any error rate spikes for 10 minutes
4. Log the rotation date in your team's incident log

---

## Dependency Scanning

Security scanning is wired into every shared CI workflow:

- `rust-ci.yml` → runs `cargo audit` on every PR to `wallet-contracts`
- `node-ci.yml` → runs `pnpm audit --audit-level moderate` on every PR to TypeScript repos

If a CVE is detected, CI will fail. Do not merge until the dependency is updated or the advisory is explicitly acknowledged.

---

## Incident Response

If you suspect a credential has been exposed:

1. **Immediately** go to the relevant platform (Render/Vercel/Neon/Upstash) and revoke the compromised credential.
2. Generate a new one and update all environments that use it.
3. Run `bash scripts/rotate-secrets.sh` for the full checklist.
4. Check Grafana logs for any anomalous activity in the window the credential was exposed.
5. Document the incident in your team's log.

> This service cannot move user funds without a valid on-chain-verified passkey signature.
> The relay only relays — it holds no private keys. Exposing a `LAUNCHTUBE_API_KEY` means
> an attacker could sponsor fee-bump transactions but **cannot steal user funds**.
