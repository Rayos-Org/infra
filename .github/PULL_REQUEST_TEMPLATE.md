## Description
<!-- Describe your changes in detail -->
<!-- If it fixes an open issue, please link to the issue here: Fixes # -->

## Impact
<!-- Which consuming repos does this change impact? -->
- [ ] wallet-contracts
- [ ] wallet-sdk
- [ ] elay-backend
- [ ] web-dashboard
- [ ] mobile-app
- [ ] demo-app

## Local Validation Checklist
<!-- Please confirm you have run the following local validations (see CONTRIBUTING.md) -->
- [ ] yamllint workflows/ docker/ observability/ passes
- [ ] shellcheck scripts/*.sh passes (if scripts modified)
- [ ] docker compose -f docker/docker-compose.local.yml config --quiet passes
- [ ] ash scripts/bootstrap-local-dev.sh runs successfully

## Additional Context
<!-- Add any other context about the pull request here. -->