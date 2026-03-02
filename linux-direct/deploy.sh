#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck source=/dev/null
  set -a
  source "${ENV_FILE}"
  set +a
else
  echo "No .env found. Copy .env.example to .env and customize if needed."
  cp "${SCRIPT_DIR}/.env.example" "${ENV_FILE}"
  echo "Created ${ENV_FILE}. Re-run deploy.sh after reviewing values."
  exit 1
fi

OPENCLAW_REPO="${OPENCLAW_REPO:-https://github.com/openclaw/openclaw.git}"
OPENCLAW_BRANCH="${OPENCLAW_BRANCH:-main}"
INSTALL_DIR="${INSTALL_DIR:-${SCRIPT_DIR}/openclaw-src}"
APP_PORT="${APP_PORT:-3000}"

command -v git >/dev/null || { echo "git is required"; exit 1; }

if [[ ! -d "${INSTALL_DIR}/.git" ]]; then
  echo "Cloning OpenClaw from ${OPENCLAW_REPO} (${OPENCLAW_BRANCH})..."
  git clone --depth 1 --branch "${OPENCLAW_BRANCH}" "${OPENCLAW_REPO}" "${INSTALL_DIR}"
else
  echo "Updating existing OpenClaw source in ${INSTALL_DIR}..."
  git -C "${INSTALL_DIR}" fetch origin "${OPENCLAW_BRANCH}" --depth 1
  git -C "${INSTALL_DIR}" checkout "${OPENCLAW_BRANCH}"
  git -C "${INSTALL_DIR}" pull --ff-only origin "${OPENCLAW_BRANCH}"
fi

cd "${INSTALL_DIR}"

if [[ -x "./deploy.sh" ]]; then
  echo "Using project-provided deploy.sh"
  APP_PORT="${APP_PORT}" ./deploy.sh
elif [[ -f "docker-compose.yml" || -f "compose.yml" ]]; then
  command -v docker >/dev/null || { echo "docker is required to run compose"; exit 1; }
  command -v docker-compose >/dev/null || docker compose version >/dev/null || { echo "docker compose is required"; exit 1; }
  echo "Starting OpenClaw with Docker Compose on port ${APP_PORT}"
  APP_PORT="${APP_PORT}" docker compose up -d
elif [[ -f "requirements.txt" ]]; then
  command -v python3 >/dev/null || { echo "python3 is required"; exit 1; }
  python3 -m venv .venv
  # shellcheck disable=SC1091
  source .venv/bin/activate
  pip install --upgrade pip
  pip install -r requirements.txt
  if [[ -f "main.py" ]]; then
    echo "Running Python app directly"
    exec python main.py
  else
    echo "requirements.txt found but no known start command. Start manually from ${INSTALL_DIR}."
  fi
else
  echo "Repository cloned, but no known runtime detected. Start OpenClaw manually from ${INSTALL_DIR}."
fi
