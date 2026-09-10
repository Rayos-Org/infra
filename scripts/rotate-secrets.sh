#!/usr/bin/env bash
# Secrets rotation runbook — prints what to do, does not do it automatically.
# Run this after any suspected credential exposure or on the quarterly rotation schedule.

echo "=== Rayos Secrets Rotation Runbook ==="
echo ""
echo "1. LAUNCHTUBE_API_KEY"
echo "   ? Go to https://launchtube.xyz and regenerate the key"
echo "   ? Update in Render dashboard for relay-backend (testnet-dev, testnet-staging)"
echo "   ? Update in GitHub Environments (if set there)"
echo ""
echo "2. RESEND_API_KEY"
echo "   ? Go to https://resend.com/api-keys and rotate"
echo "   ? Update in Render dashboard"
echo ""
echo "3. DATABASE_URL (Neon)"
echo "   ? Go to Neon dashboard ? Connection Settings ? Rotate password"
echo "   ? Update Render env var immediately after rotation"
echo "   ? Verify relay-backend reconnects without restart (connection pooling)"
echo ""
echo "4. REDIS_URL (Upstash)"
echo "   ? Go to Upstash console ? Database ? Reset password"
echo "   ? Update Render env var"
echo ""
echo "5. After all rotations:"
echo "   ? Verify relay-backend health endpoint: GET /api/health"
echo "   ? Check Grafana for any error spikes"
echo "   ? Log the rotation date in the team's incident log"

