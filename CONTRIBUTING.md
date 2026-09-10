# Contributing to `infra`

Thank you for contributing to the TeamRayos infrastructure repo. Changes here affect every other repository in the organization, so please read this guide before opening a PR.

---

## ⚠️ High-Impact Repo

A bug in a reusable GitHub Actions workflow here will **fail CI across every consuming repo** on their next run. Before opening a PR:

1. Test your changes locally using the validation commands below
2. Describe the impact in your PR description — which repos are affected and how

---

## Branching & Commits

- Branch off `main` using the naming convention: `feat/`, `fix/`, `docs/`, `chore/`
- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`
- Keep PRs focused — one logical change per PR

---

## Local Validation Before Opening a PR

Run these checks locally before pushing:

```bash
# 1. Validate all YAML files
pip install yamllint
yamllint workflows/ docker/ observability/

# 2. Check shell script syntax
shellcheck scripts/*.sh

# 3. Validate Docker Compose syntax
docker compose -f docker/docker-compose.local.yml config --quiet
docker compose -f docker/docker-compose.ci.yml config --quiet

# 4. Run the bootstrap script end-to-end
bash scripts/bootstrap-local-dev.sh
```

All four must pass before your PR is ready for review.

---

## PR Requirements

- [ ] CI (`ci.yml`) is green
- [ ] If modifying a reusable workflow: describe which consuming repos are impacted
- [ ] If adding a new environment variable: updated all three `environments/*.env.example` files with a comment
- [ ] If modifying scripts: run `shellcheck` locally

---

## What Belongs in This Repo

✅ Reusable GitHub Actions workflows  
✅ Docker Compose files for local dev / CI  
✅ Environment variable templates (`.env.example` only, never real values)  
✅ Observability configuration  
✅ Bootstrap and maintenance scripts  
✅ Documentation for contributors  

❌ Application code  
❌ Real secrets or credentials (use the platform secrets manager)  
❌ Terraform or IaC until we have multiple cloud environments to manage  

---

## Documentation

All documentation lives in [`docs/`](./docs/). If your change affects how a workflow works, how an environment variable is used, or how repos wire together, update the relevant doc in the same PR.

---

## Questions?

Open a GitHub Discussion in this repo or reach out in the Stellar Developer Discord.
