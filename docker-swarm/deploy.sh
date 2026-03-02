#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
STACK_FILE="${SCRIPT_DIR}/docker-stack.yml"

[[ -f "${ENV_FILE}" ]] || { echo "Missing ${ENV_FILE}"; exit 1; }
[[ -f "${STACK_FILE}" ]] || { echo "Missing ${STACK_FILE}"; exit 1; }

# shellcheck source=/dev/null
set -a
source "${ENV_FILE}"
set +a

STACK_NAME="${STACK_NAME:-openclaw}"

command -v docker >/dev/null || { echo "docker is required"; exit 1; }

if ! docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q '^active$'; then
  echo "Docker Swarm is not active. Initialize it with: docker swarm init"
  exit 1
fi

echo "Deploying stack '${STACK_NAME}' using ${STACK_FILE}"
docker stack deploy --compose-file "${STACK_FILE}" "${STACK_NAME}"

echo "Done. Check status with: docker stack services ${STACK_NAME}"
