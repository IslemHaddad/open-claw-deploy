# AGENTS.md

## Purpose
This repository contains deployment wrappers for OpenClaw in three environments:
- `linux-direct/`
- `docker-swarm/`
- `kubernetes/`

Your primary goal is to validate deployment script changes safely and consistently.

## Fast start checklist
1. Read `README.md` for deployment modes.
2. Run static/syntax checks first (do not assume Docker/Kubernetes are available).
3. Run environment-specific validation commands listed below.
4. If runtime infrastructure is unavailable, report that as an environment limitation and still provide all static validation results.

## Required validation for changes
When you modify any deploy script or manifest, run these checks from repo root:

```bash
bash -n linux-direct/deploy.sh
bash -n docker-swarm/deploy.sh
bash -n kubernetes/deploy.sh
```

### Linux direct checks
```bash
test -f linux-direct/.env.example
```

### Docker Swarm checks
```bash
test -f docker-swarm/.env
test -f docker-swarm/docker-stack.yml
```
If Docker is available, also run:
```bash
docker compose -f docker-swarm/docker-stack.yml config
```
(Use this for schema validation even though deployment uses `docker stack deploy`.)

### Kubernetes checks
```bash
test -f kubernetes/.env
test -f kubernetes/deployment.yaml.tpl
set -a && source kubernetes/.env && set +a && envsubst < kubernetes/deployment.yaml.tpl > /tmp/openclaw-k8s.yaml
```
If `kubectl` is available, also run:
```bash
kubectl apply --dry-run=client -f /tmp/openclaw-k8s.yaml
```

## Change guidance
- Keep scripts POSIX/Bash-safe and preserve `set -euo pipefail`.
- Preserve existing environment variable names unless intentionally migrating with documentation updates.
- Prefer fail-fast error messages that state what dependency is missing and how to fix it.
- Update `README.md` when behavior, required env vars, or deploy flow changes.

## PR expectations for agents
Include in your summary:
- What changed.
- Which deployment mode(s) were affected.
- Exact validation commands executed and their outcomes.
- Any commands skipped due to missing local infrastructure.
