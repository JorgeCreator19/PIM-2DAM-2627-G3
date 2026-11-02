# Windows (PowerShell): levanta los servicios de desarrollo. Ejecutar desde la raíz del repo:
#   .\infra\scripts\dev-up.ps1
if (-not (Test-Path .env)) { Copy-Item .env.example .env; Write-Host "Creado .env: revisa las contraseñas." }
docker compose --env-file .env -f infra/docker-compose.yml up -d
docker compose --env-file .env -f infra/docker-compose.yml ps