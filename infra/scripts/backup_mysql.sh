#!/usr/bin/env bash
# Copia de seguridad de MySQL (del servidor de pruebas / demo). Uso desde la raíz del repo:
#   ./infra/scripts/backup_mysql.sh
# Programarla a diario con cron:  0 4 * * * cd /ruta/al/repo && ./infra/scripts/backup_mysql.sh
set -euo pipefail

cd "$(dirname "$0")/../.."
mkdir -p infra/backups
FILE="infra/backups/vapor_$(date +%Y%m%d_%H%M%S).sql.gz"

docker compose --env-file .env -f infra/docker-compose.yml exec -T mysql \
  sh -c 'mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" --single-transaction --routines "$MYSQL_DATABASE"' \
  | gzip > "$FILE"

# Conservar solo las 14 copias más recientes
ls -1t infra/backups/vapor_*.sql.gz | tail -n +15 | xargs -r rm --
echo "Copia guardada en $FILE"