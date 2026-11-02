-- Datos de prueba SOLO para desarrollo. Nunca en la demo pública.
-- Se cargan a mano después de levantar MySQL:
--   docker compose -f infra/docker-compose.yml --env-file .env exec -T mysql \
--     sh -c 'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' < infra/seed/seed_dev.sql
--
-- Las contraseñas NO valen para iniciar sesión: hash_pass es un texto de relleno.
-- Para usuarios reales de prueba, registraos desde la app.

INSERT INTO usuario (email, hash_pass, nombre, juegos, rol_juego, rol_id) VALUES
  ('jorge@vapor.local',  'relleno-no-es-argon2', 'jorge',  JSON_ARRAY('Valorant'), 'Duelista', 3),
  ('matias@vapor.local', 'relleno-no-es-argon2', 'matias', JSON_ARRAY('League of Legends'),  'Mid',      3),
  ('iker@vapor.local',   'relleno-no-es-argon2', 'iker',   JSON_ARRAY('Rocket League'),      'Delantero',3),
  ('prueba@vapor.local', 'relleno-no-es-argon2', 'prueba', NULL,                             NULL,       1);

-- jorge (1) y matias (2) son amigos; iker (3) le ha pedido amistad a jorge
INSERT INTO amistad (usuario_a, usuario_b, estado, solicitado_por) VALUES
  (1, 2, 'amigo', 1),
  (1, 3, 'pendiente', 3);
