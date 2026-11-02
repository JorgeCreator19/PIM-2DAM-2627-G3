# Protocolo cliente-servidor de Vapor

**Fuente de verdad** del contrato entre la app y el servidor. Se cambia SOLO con un PR que revisen
cliente (Matías/Iker) y servidor (Jorge). Matías puede programar contra un servidor falso que devuelva estos JSON.

Versión: 0.1 (MVP) - Decisión del MVP: **un dispositivo activo por cuenta** (ver `decisiones/0002`).

## REST

- JSON en el cuerpo, cabecera `Authorization: Bearer <access token>` salvo en `/auth/*`.
- Errores siempre con la misma forma: `{"error":"codigo","message":"texto legible"}`.

| Método y ruta | Para qué | Historia |
|---|---|---|
| `POST /auth/register` | Crear cuenta (email, contraseña, nombre) | HO1 |
| `POST /auth/login` | Devuelve access + refresh token y el usuario | HO1 |
| `POST /auth/refresh` - `POST /auth/logout` | Renovar token - cerrar sesión | HO1 |
| `POST /auth/forgot` - `POST /auth/reset` | Enviar enlace de recuperación - contraseña nueva | HO12 |
| `GET /me` - `PATCH /me` | Ver y editar mi perfil | HO11 |
| `GET /users/search?q=` - `GET /users/{id}` | Buscar jugadores - ver perfil | HO3 |
| `GET /friends` - `POST /friends/requests` | Amigos y solicitudes - enviar solicitud | HO3 |
| `POST /friends/requests/{id}/accept` - `/reject` - `DELETE /friends/{id}` | Aceptar, rechazar, eliminar | HO3 |
| `POST /blocks/{id}` - `DLETE /blocks/{id}` - `GET /blocks` | Bloquear y desbloquear | HO17 |
| `POST /devices` - `POST /devices/{id}/prekeys` | Registrar claves públicas - reponer prekeys | HO29 |
| `GET /users/{id}/keys` | Claves del dispositivo + una prekey (se marca usada) | HO29 |
| `POST /files` - `GET /files/{id}` | URL de subida - URL de descarga del blob cifrado | HO22 |
| `GET /health` | Comprobar que el servidor está vivo | — |

Códigos: 200/201 bien - 400 datos mal - 401 sin sesión - 403 bloqueado o sin permiso - 404 no existe -
409 duplicado (email o nombre) - 429 demasiadas peticiones.

> TO-DO (Jorge + Matías, antes de S3): se escribe aquí el JSON exacto de petición y respuesta de cada ruta de HO1.

## WebSocket `/ws`

Un JSON por mensaje. El navegador no permite cabeceras en un WebSocket, así que **el primer mensaje
es la autenticación**, si en 5 segundos no llega, el servidor se cierra.

```json
-> {"t":"auth","token":"<access token>"}
<- {"t":"auth.ok","user_id":42}
-> {"t":"msg.send","cid":"<uuid del cliente>","to":17,"kind":0,"body":"<base64 cifrado>"}
<- {"t":"msg.ack","cid":"…","id":9001,"ts":"2026-12-21T18:03:11.250Z"}
<- {"t":"msg.new","id":9002,"from":17,"kind":1,"body":"…","ts":"…"}
-> {"t":"msg.delivered","id":9002}
<- {"t":"msg.status","id":9001,"status":"delivered"}
<- {"t":"friend.request","from":{…}}
<- {"t":"presence","user":17,"online":true}
<- {"t":"error","code":"blocked","cid":"…"}
```

- `cid` lo genera el cliente: si reenvía tras una reconexión, el servidor no duplica (UNIQUE en BD).
- `kind` 0 = mensaje PreKey de Olm (abre sesión) - 1 = normal. El servidor **nunca** lee `body`.
- Al recibir `msg.delivered`, el servidor borra el mensaje de su cola.
- Ping/pong cada 30 s.
- Si el destinatario te ha bloqueado: `error` con `code: "blocked"` y no se reenvía nada (HO17).

## Contenido cifrado (lo que hay DENTRO de `body`, solo lo ven los clientes)

```json
{"v":1,"type":"text","text":"gg wp"}
{"v":1,"type":"image","file_id":123,"key":"<base64>","sha256":"<hex>","w":1280,"h":720}
```

## Historial de cambios

| Fecha | Cambio | PR |
|---|---|---|
| 30/10/2026 | Versión inicial a partir de la guía del equipo | — |
