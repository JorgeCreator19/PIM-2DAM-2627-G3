# 0002 · Un dispositivo activo por cuenta en el MVP

- **Fecha:** 28/10/2026
- **Estado:** aceptada
- **Quién decide:** todos

## Contexto

Con varios dispositivos por cuenta, cada mensaje hay que cifrarlo para cada dispositivo y sincronizar el historial cifrado.

## Decisión

En el MVP, iniciar sesión en un dispositivo nuevo desactiva el anterior (`dispositivo.activo`).
El historial no se copia. El multidispositivo con clave de recuperación es la HO13 (Fase 2).

## Consecuencias

Mucho menos trabajo en HO29. Limitación conocida que se explica en la memoria.
