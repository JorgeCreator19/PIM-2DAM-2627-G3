# 0001 · vodozemac (Olm) para el cifrado de extremo a extremo

- **Fecha:** 28/10/2026
- **Estado:** aceptada
- **Quién decide:** todos (dueño del núcleo: Iker)

## Contexto

Vapor promete E2EE en todos los mensajes. Implementar criptografía propia es inseguro e inviable en 24 semanas.

## Decisión

Usar **vodozemac** (Rust, Apache-2.0, la que usa Matrix/Element): Olm para chats 1:1, que combina
un acuerdo de claves triple Diffie-Hellman (equivalente a X3DH) con el Double Ratchet. Grupos (Fase 2): MLS o Megolm.

## Alternativas descartadas

- libsignal: licencia AGPL y API pensada para el servidor de Signal.
- Criptografía propia: descartada siempre.

## Consecuencias

- En la memoria se describe como «Olm (Double Ratchet + triple DH)», no como «el protocolo Signal».
- Funciona también en WebAssembly para la versión web.
