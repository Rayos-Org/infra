# Security Policy

## Scope

This repository contains **no application code and no secrets**. It holds:
- GitHub Actions workflow templates
- Docker Compose files
- Environment variable templates (`.env.example` — no real values)
- Shell scripts

The primary security surface of this repo is ensuring **no real credentials are accidentally committed**.

---

## Reporting a Vulnerability

If you discover a security issue in any TeamRayos repository (including this one), please **do not open a public GitHub issue**.

Report vulnerabilities to the maintainers through the organization's official disclosure channel. We will acknowledge receipt within 48 hours and provide a timeline for resolution.

---

## Secrets Policy

- `.env` files are blocked by `.gitignore` in every repo
- All `*.env.example` files in this repo contain only placeholder values
- Real credentials are set exclusively via platform secrets managers (Render dashboard, Vercel, GitHub Environments)
- Secrets are rotated quarterly or immediately upon exposure — see [`docs/secrets-and-security.md`](./docs/secrets-and-security.md)

---

## Trust Model

The relay-backend that this `infra` repo helps deploy **cannot move user funds** without a valid on-chain-verified passkey signature. Exposing a relay API key or deploy hook cannot result in user fund theft. See the relay-backend's own `SECURITY.md` for its full trust model.

---

## Supported Versions

Only the `main` branch receives active maintenance and security updates.
