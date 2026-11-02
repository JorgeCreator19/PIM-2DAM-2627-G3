-- ==========================================================================
-- Vapor - Migración 001 - Tablas del MVP
-- Fuente: Vapor_Modelo_de_datos.xlsx (modelo E-R conceptual), orden 1-11.
--
-- REGLA: una migración ya aplicada NUNCA se edita. Para cambiar algo,
-- se crea 002_lo_que_sea.sql con ALTER TABLE.
--
-- En desarrollo, Docker ejecuta esta carpeta sola la primera vez que se crea
-- el volumen de MySQL. Para empezar de cero:
--   docker compose -f infra/docker-compose.yml --env-file .env down -v
-- ==========================================================================

SET NAMES utf8mb4;

-- Control de migraciones aplicadas
CREATE TABLE migracion (
  version     INT          NOT NULL PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  aplicada_en DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 1. rol
CREATE TABLE rol (
  id     INT         NOT NULL PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Datos fijos: el Invitado no tiene cuenta, así que no es un rol guardado
INSERT INTO rol (id, nombre) VALUES
  (1, 'usuario'),
  (2, 'organizador'),
  (3, 'desarrollador'),
  (4, 'administrador');

-- 2. usuario (HO1, HO3, HO11, HO12)
CREATE TABLE usuario (
  id         BIGINT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
  email      VARCHAR(255) NOT NULL UNIQUE,
  hash_pass  VARCHAR(255) NOT NULL,              -- cadena Argon2id completa
  nombre     VARCHAR(32)  NOT NULL UNIQUE,       -- nombre público
  avatar_key VARCHAR(255) NULL,                  -- objeto en S3 (no cifrado)
  juegos     JSON         NULL,                  -- MVP; en Fase 2 -> usuario_juego
  rol_juego  VARCHAR(64)  NULL,
  estado     ENUM('activo','suspendido','eliminado') NOT NULL DEFAULT 'activo',
  rol_id     INT          NOT NULL DEFAULT 1,
  creado_en  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_usuario_rol
  FOREIGN KEY (rol_id) REFERENCES rol(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. refresh_token (HO1)
CREATE TABLE refresh_token (
  id         BIGINT   NOT NULL AUTO_INCREMENT PRIMARY KEY,
  usuario_id BIGINT   NOT NULL,
  hash_token CHAR(64) NOT NULL UNIQUE,           -- SHA-256 en hex, nunca el token
  expira_en  DATETIME NOT NULL,
  revocado   BOOLEAN  NOT NULL DEFAULT FALSE,
  creado_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_refresh_usuario
  FOREIGN KEY (usuario_id) REFERENCES usuario(id)
  ON DELETE CASCADE,
  INDEX idx_refresh_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. reset_token (HO12)
CREATE TABLE reset_token (
  id         BIGINT   NOT NULL AUTO_INCREMENT PRIMARY KEY,
  usuario_id BIGINT   NOT NULL,
  hash_token CHAR(64) NOT NULL UNIQUE,
  expira_en  DATETIME NOT NULL,                  -- 30 min
  usado      BOOLEAN  NOT NULL DEFAULT FALSE,
  creado_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reset_usuario
  FOREIGN KEY (usuario_id) REFERENCES usuario(id)
  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. dispositivo (HO29) — solo claves PÚBLICAS
CREATE TABLE dispositivo (
  id           BIGINT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
  usuario_id   BIGINT       NOT NULL,
  identity_key VARCHAR(64)  NOT NULL,            -- Curve25519 (base64)
  signing_key  VARCHAR(64)  NOT NULL,            -- Ed25519 (base64)
  token_push   VARCHAR(255) NULL,                -- FCM / APNs
  activo       BOOLEAN      NOT NULL DEFAULT TRUE, -- MVP: uno activo por cuenta
  creado_en    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_dispositivo_usuario
  FOREIGN KEY (usuario_id) REFERENCES usuario(id)
  ON DELETE CASCADE,
  INDEX idx_dispositivo_usuario (usuario_id, activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. prekey (HO29) — 50 one-time keys por dispositivo
CREATE TABLE prekey (
  id             BIGINT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
  dispositivo_id BIGINT      NOT NULL,
  key_id         VARCHAR(32) NOT NULL,           -- id dentro de vodozemac
  clave          VARCHAR(64) NOT NULL,           -- clave pública (base64)
  usada          BOOLEAN     NOT NULL DEFAULT FALSE,
  CONSTRAINT fk_prekey_dispositivo 
  FOREIGN KEY (dispositivo_id) REFERENCES dispositivo(id) 
  ON DELETE CASCADE,
  CONSTRAINT uq_prekey UNIQUE (dispositivo_id, key_id),
  INDEX idx_prekey_libres (dispositivo_id, usada)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 7. amistad (HO3, HO17) — relación reflexiva, siempre usuario_a < usuario_b
CREATE TABLE amistad (
  usuario_a      BIGINT   NOT NULL,
  usuario_b      BIGINT   NOT NULL,
  estado         ENUM('pendiente','amigo','bloqueado') NOT NULL,
  solicitado_por BIGINT   NULL,                  -- Añadido al modelo: quién envió la solicitud (para saber quién puede aceptarla)
  bloqueado_por  BIGINT   NULL,                  -- quién bloqueó (si estado = 'bloqueado')
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_a, usuario_b),
  CONSTRAINT fk_amistad_a 
  FOREIGN KEY (usuario_a) REFERENCES usuario(id),
  CONSTRAINT fk_amistad_b 
  FOREIGN KEY (usuario_b) REFERENCES usuario(id),
  CONSTRAINT fk_amistad_solicita 
  FOREIGN KEY (solicitado_por) REFERENCES usuario(id),
  CONSTRAINT fk_amistad_bloquea 
  FOREIGN KEY (bloqueado_por) REFERENCES usuario(id),
  CONSTRAINT ck_amistad_orden CHECK (usuario_a < usuario_b),
  INDEX idx_amistad_b (usuario_b)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 8. conversacion (HO4) — comunidad_id se añade en Fase 2 con ALTER TABLE
CREATE TABLE conversacion (
  id        BIGINT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(80) NULL,                    -- nulo en los chats privados
  tipo      ENUM('privada','grupo','canal') NOT NULL DEFAULT 'privada',
  protocolo ENUM('olm','mls')              NOT NULL DEFAULT 'olm',
  creada_en DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 9. participante (HO4) — usuario <--> conversación
CREATE TABLE participante (
  conversacion_id     BIGINT   NOT NULL,
  usuario_id          BIGINT   NOT NULL,
  rol_en_conversacion ENUM('miembro','admin') NOT NULL DEFAULT 'miembro',
  estado              ENUM('activo','salido') NOT NULL DEFAULT 'activo',
  unido_en            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (conversacion_id, usuario_id),
  CONSTRAINT fk_part_conv 
  FOREIGN KEY (conversacion_id) REFERENCES conversacion(id) 
  ON DELETE CASCADE,
  CONSTRAINT fk_part_usuario 
  FOREIGN KEY (usuario_id) REFERENCES usuario(id),
  INDEX idx_part_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 10. mensaje_cifrado (HO4, HO22, HO29) — cola: se borra al entregarse
CREATE TABLE mensaje_cifrado (
  id                BIGINT     NOT NULL AUTO_INCREMENT PRIMARY KEY,
  conversacion_id   BIGINT     NOT NULL,
  emisor_disp       BIGINT     NOT NULL,
  receptor_disp     BIGINT     NULL,             -- nulo en grupos/canales (Fase 2)
  cid               CHAR(36)   NOT NULL,         -- UUID del cliente (anti-duplicados)
  kind              TINYINT    NOT NULL,         -- 0 = PreKey (abre sesión), 1 = normal
  contenido_cifrado MEDIUMTEXT NOT NULL,         -- base64; el servidor no lo lee nunca
  enviado_en        DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  entregado_en      DATETIME(3) NULL,
  CONSTRAINT fk_msg_conv
  FOREIGN KEY (conversacion_id) REFERENCES conversacion(id)
  ON DELETE CASCADE,
  CONSTRAINT fk_msg_emisor
  FOREIGN KEY (emisor_disp) REFERENCES dispositivo(id)
  ON DELETE CASCADE,
  CONSTRAINT fk_msg_receptor
  FOREIGN KEY (receptor_disp) REFERENCES dispositivo(id)
  ON DELETE CASCADE,
  CONSTRAINT uq_msg_cid UNIQUE (emisor_disp, cid),
  CONSTRAINT ck_msg_kind CHECK (kind IN (0, 1)),
  INDEX idx_msg_pendientes (receptor_disp, entregado_en)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 11. archivo_cifrado (HO22) — mensaje_id nulo hasta que se envía el mensaje
CREATE TABLE archivo_cifrado (
  id              BIGINT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
  mensaje_id      BIGINT       NULL,
  dispositivo_id  BIGINT       NOT NULL,         -- quién subió el blob
  clave_objeto_s3 VARCHAR(255) NOT NULL UNIQUE,
  size            BIGINT       NOT NULL,         -- bytes del blob cifrado
  sha256          CHAR(64)     NOT NULL,
  creado_en       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_archivo_msg 
  FOREIGN KEY (mensaje_id) REFERENCES mensaje_cifrado(id) ON DELETE SET NULL,
  CONSTRAINT fk_archivo_disp 
  FOREIGN KEY (dispositivo_id) REFERENCES dispositivo(id) ON DELETE CASCADE,
  CONSTRAINT ck_archivo_size CHECK (size > 0 AND size <= 10485760)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO migracion (version, nombre) VALUES (1, '001_init');
