# 0003 · Caddy como proxy inverso para TLS 1.3

- **Fecha:** 28/10/2026
- **Estado:** aceptada
- **Quién decide:** Jorge

## Contexto

El stack exige WebSocket sobre TLS 1.3. Programar TLS dentro del servidor C++ añade una complejidad exajerada
y un riesgo al ser un lenguaje difícil de manejar.

## Decisión

El servidor C++ habla en claro dentro de la máquina; **Caddy** pone HTTPS/WSS (TLS 1.3, certificados automáticos)
y las cabeceras COOP/COEP de la versión web. Configuración en `infra/caddy/Caddyfile`.

## Consecuencias

En local se usa `http://` y `ws://`. En la demo todo el tráfico externo va cifrado.
