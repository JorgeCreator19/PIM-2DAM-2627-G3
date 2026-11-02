#!/usr/bin/env bash
# Linux / macOS: levanta los servicios de desarrollo. Ejecutar desde la raíz del repo:
#   ./infra/scripts/dev-up.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
[[ -f .env ]] || { cp .env.example .env; echo "Creado .env: revisa las contraseñas."; }
docker compose --env-file .env -f infra/docker-compose.yml up -d
docker compose --env-file .env -f infra/docker-compose.yml ps
