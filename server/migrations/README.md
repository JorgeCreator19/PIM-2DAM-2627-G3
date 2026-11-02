# Migraciones SQL numeradas: `001_init.sql`, `002_….sql`…

- Una migración ya aplicada **no se edita nunca**: los cambios van en una nueva con `ALTER TABLE`.
- Cada migración termina con `INSERT INTO migracion (version, nombre) VALUES (N, '00N_nombre');`
- En desarrollo, Docker las ejecuta solas al crear el volumen de MySQL por primera vez.
- Fuente del diseño: `docs/modelo-datos/` (modelo E-R conceptual).
