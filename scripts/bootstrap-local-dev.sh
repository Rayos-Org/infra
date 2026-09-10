#!/usr/bin/env bash
set -euo pipefail

check_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "?  Required tool '$1' not found. Install it and re-run."
    exit 1
  }
}
echo "Checking prerequisites..."
check_tool docker
check_tool pnpm
check_tool node
check_tool stellar

echo "Starting local Docker services (Postgres, Redis)..."
docker compose -f "$(dirname "$0")/../docker/docker-compose.local.yml" up -d --wait

echo "Applying Drizzle migrations..."
if [ -d "$(dirname "$0")/../../relay-backend" ]; then
  (cd "$(dirname "$0")/../../relay-backend" && pnpm install && pnpm db:push)
else
  echo "??  relay-backend directory not found at ../relay-backend, skipping migrations."
fi

echo "Checking Soroban Testnet RPC health..."
curl -sf https://soroban-testnet.stellar.org/health > /dev/null || echo "??  Testnet RPC not reachable; check your connection."

echo ""
echo "?????????????????????????????????????????????"
echo "?  Local dev stack is running"
echo ""
echo "  Postgres    ?  postgresql://postgres:password@localhost:5432/relay_dev"
echo "  Redis       ?  redis://localhost:6379"
echo "  Soroban RPC ?  https://soroban-testnet.stellar.org (testnet)"
echo ""
echo "  Factory Contract  ?  CCCAMWJOF7IYTVCU7SR6HFTNH5XRMDMWPYN464NY5BCKUPMUM64RZ5CH"
echo "  Policy Contract   ?  CCDM3O2SXX3E24MCWLRK5YBVQHJCA4OQKJFF6KWCK6FHZS65DGMT6DOY"
echo ""
echo "  To start relay-backend:"
echo "    cd ../relay-backend && cp ../infra/environments/testnet-dev.env.example .env"
echo "    # Fill in LAUNCHTUBE_API_KEY and RESEND_API_KEY"
echo "    pnpm start:dev"
echo ""
echo "  Relay API will be at: http://localhost:3000/api"
echo "  Swagger docs at:      http://localhost:3000/api/docs"
echo "?????????????????????????????????????????????"

