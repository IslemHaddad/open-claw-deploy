#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
TEMPLATE_FILE="${SCRIPT_DIR}/deployment.yaml.tpl"
RENDERED_FILE="${SCRIPT_DIR}/deployment.yaml"

[[ -f "${ENV_FILE}" ]] || { echo "Missing ${ENV_FILE}"; exit 1; }
[[ -f "${TEMPLATE_FILE}" ]] || { echo "Missing ${TEMPLATE_FILE}"; exit 1; }

# shellcheck source=/dev/null
set -a
source "${ENV_FILE}"
set +a

K8S_NAMESPACE="${K8S_NAMESPACE:-openclaw}"
OPENCLAW_IMAGE="${OPENCLAW_IMAGE:-ghcr.io/openclaw/openclaw:latest}"
OPENCLAW_PORT="${OPENCLAW_PORT:-3000}"
REPLICAS="${REPLICAS:-1}"

command -v kubectl >/dev/null || { echo "kubectl is required"; exit 1; }
command -v envsubst >/dev/null || { echo "envsubst is required (install gettext)"; exit 1; }

echo "Ensuring namespace '${K8S_NAMESPACE}' exists..."
kubectl get namespace "${K8S_NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${K8S_NAMESPACE}"

echo "Rendering manifest to ${RENDERED_FILE}"
envsubst < "${TEMPLATE_FILE}" > "${RENDERED_FILE}"

echo "Applying OpenClaw to namespace '${K8S_NAMESPACE}'"
kubectl apply -f "${RENDERED_FILE}"

echo "Done. Check status with: kubectl -n ${K8S_NAMESPACE} get pods,svc"
