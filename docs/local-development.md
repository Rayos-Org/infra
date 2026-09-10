# Local Development Guide

This guide walks you through setting up the full TeamRayos stack on your local machine.

---

## Prerequisites

Before running the bootstrap script, make sure you have the following installed:

| Tool | Version | Install |
|---|---|---|
| Docker Desktop | Latest | [docker.com](https://www.docker.com/products/docker-desktop/) |
| Node.js | ≥ 22 | [nodejs.org](https://nodejs.org/) |
| pnpm | ≥ 9 | `npm install -g pnpm` |
| Stellar CLI | Latest | [stellar.org/docs](https://developers.stellar.org/docs/tools/stellar-cli) |

---

## One-Command Setup

```bash
# From the infra repo root
bash scripts/bootstrap-local-dev.sh
```

That single command will:
1. Verify all prerequisite tools are installed
2. Start **Postgres 16** + **Redis 7** via Docker
3. Apply Drizzle schema migrations to the local database
4. Verify connectivity to the public Stellar Testnet RPC
5. Print a summary with all connection strings and deployed contract addresses

---

## What's Running After Bootstrap

| Service | URL | Credentials |
|---|---|---|
| Postgres | `postgresql://postgres:password@localhost:5432/relay_dev` | Local Docker only |
| Redis | `redis://localhost:6379` | Local Docker only |
| Soroban RPC | `https://soroban-testnet.stellar.org` | Public, no key needed |

---

## Starting relay-backend Manually

After bootstrap, start the relay backend in a new terminal:

```bash
cd ../relay-backend

# Copy the pre-filled testnet template
cp ../infra/environments/testnet-dev.env.example .env

# Fill in the two API keys (everything else is already set):
#   LAUNCHTUBE_API_KEY → https://launchtube.xyz
#   RESEND_API_KEY     → https://resend.com

pnpm install
pnpm start:dev
```

Relay API: `http://localhost:3000/api`  
Swagger Docs: `http://localhost:3000/api/docs`

---

## Stopping the Local Stack

```bash
docker compose -f docker/docker-compose.local.yml down
```

To fully wipe volumes (reset the database):

```bash
docker compose -f docker/docker-compose.local.yml down -v
```

---

## Testnet Contract Addresses

These are already pre-filled in `environments/testnet-dev.env.example`:

| Contract | Address |
|---|---|
| Factory | `CCCAMWJOF7IYTVCU7SR6HFTNH5XRMDMWPYN464NY5BCKUPMUM64RZ5CH` |
| Policy | `CCDM3O2SXX3E24MCWLRK5YBVQHJCA4OQKJFF6KWCK6FHZS65DGMT6DOY` |

---

## Troubleshooting

**Docker fails to start Postgres/Redis**  
Ensure Docker Desktop is running. Check for port conflicts on `5432` or `6379`.

**`stellar` command not found**  
Install the Stellar CLI from [developers.stellar.org/docs/tools/stellar-cli](https://developers.stellar.org/docs/tools/stellar-cli).

**`pnpm db:push` fails**  
Ensure Postgres is healthy first: `docker compose -f docker/docker-compose.local.yml ps`

**Testnet RPC not reachable**  
This is the public SDF testnet — check your internet connection or try again shortly. There are no API keys required.
