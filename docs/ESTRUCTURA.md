# Estructura del repositorio

Vapor es un **monorepo**: un solo repositorio con todas las partes (app, núcleo Rust, servidor,
infraestructura y documentación). Así un cambio que toca cliente y servidor va en un mismo PR,
el CI lo prueba todo junto y nadie trabaja con una versión vieja de otra parte.

Cada carpeta tiene **un dueño** que decide sobre ella y **un revisor** que lee sus PR.

```
PIM-2DAM-2627-G3/
├── README.md                   Qué es Vapor y cómo arrancarlo todo
├── .env.example                  Plantilla de variables (contraseñas, puertos) → se copia a .env
├── .gitignore                    Lo que Git no debe subir nunca (secretos, compilados, modelos)
├── .gitattributes                Finales de línea iguales en Windows/Linux/macOS; marca binarios y generados
├── .editorconfig                 Sangría y codificación iguales en todos los editores
├── .vscode/extensions.json       Extensiones de VS Code recomendadas (Flutter, Rust, CMake…)
│
├── .github/                    GitHub: automatización y plantillas
│   ├── workflows/ci.yml          CI en cada PR: compila y prueba server, core y app
│   ├── workflows/pages.yml       Publica site/ en GitHub Pages
│   ├── pull_request_template.md  Checklist que aparece al abrir un PR (definición de hecho)
│   ├── ISSUE_TEMPLATE/           Plantillas para crear un error o una tarea
│   └── CODEOWNERS                Pide revisión automática al revisor de cada carpeta
│
├── app/                        Cliente Flutter (Matías · Iker · Jorge)
│   ├── README.md                 Cómo crear el proyecto Flutter y conectar Rust
│   ├── flutter_rust_bridge.yaml  Dónde está el núcleo Rust y dónde se genera el código Dart
│   ├── lib/                      Código Dart (core/, features/, src/rust/)
│   ├── assets/                   Imágenes y el modelo ONNX (este se descarga, no se sube)
│   ├── test/                     Tests unitarios y de blocs
│   └── integration_test/         Tests de punta a punta con el servidor real
│
├── core/                       Núcleo Rust (Iker)
│   ├── Cargo.toml / Cargo.lock   Dependencias y versiones exactas
│   ├── src/api/                  Lo ÚNICO que ve Flutter
│   ├── src/crypto/               Cifrado de mensajes (Olm) y de archivos
│   ├── src/moderation/           Clasificador +18
│   ├── src/error.rs              Errores del núcleo
│   ├── tests/                    Tests de integración del núcleo
│   └── test_data/                Imágenes de prueba seguras para el clasificador
│
├── server/                     Servidor C++ (Jorge)
│   ├── CMakeLists.txt            Cómo se compila: librería, ejecutable y tests
│   ├── CMakePresets.json         Configuraciones listas: debug, release, ci
│   ├── vcpkg.json                Librerías C++ que instala vcpkg
│   ├── .clang-format / .clang-tidy  Estilo y análisis estático
│   ├── src/                      Código del servidor, una carpeta por módulo
│   ├── migrations/               SQL numerado que crea y cambia la base de datos
│   └── tests/                    Tests con GoogleTest
│
├── infra/                      Infraestructura (Jorge, con Matías para el servidor de pruebas)
│   ├── docker-compose.yml        MySQL, SeaweedFS, Mailpit y (en la demo) Caddy
│   ├── caddy/Caddyfile           HTTPS/TLS 1.3, proxy al servidor y versión web
│   ├── seed/seed_dev.sql         Datos de prueba para desarrollo
│   ├── scripts/                  Arrancar servicios, copias de seguridad, descargar el modelo
│   └── k6/                       Pruebas de carga (S8)
│
├── docs/                       Documentación (todos)
│   ├── ESTRUCTURA.md             Este archivo
│   ├── protocolo.md              Contrato cliente-servidor (REST + WebSocket)
│   ├── decisiones/               Por qué se eligió cada cosa (ADR)
│   ├── actas/                    Reuniones, demos y respuestas del tutor
│   ├── modelo-datos/             Diagrama E-R y diccionario de datos
│   ├── pruebas/                  Resultados de pruebas para la memoria
│   └── memoria/                  Memoria final y presentación
│
└── site/                       Página informativa de Vapor (Matías)
```

---

## Archivos de la raíz

| Archivo | Qué es y por qué está |
|---|---|
| `README.md` | Lo primero que ve cualquiera en GitHub: qué es Vapor, quién lo hace y cómo ponerlo en marcha. Si los pasos de instalación cambian, se actualiza aquí. |
| `.env.example` | Lista de todas las variables de configuración con valores de ejemplo. Cada uno lo copia a `.env` y pone sus contraseñas. El servidor C++ y Docker leen de `.env`. |
| `.gitignore` | Evita subir secretos (`.env`, claves de firma `.jks`, certificados), carpetas de compilación (`build/`, `target/`, `.dart_tool/`) y el modelo ONNX (10 MB). |
| `.gitattributes` | Fuerza finales de línea LF para que Windows no marque cada archivo como cambiado. Marca binarios (PNG, ONNX, XLSX) y el código generado por flutter_rust_bridge para que GitHub lo oculte en los PR. |
| `.editorconfig` | 2 espacios en Dart/YAML, 4 en Rust/C++, UTF-8. VS Code y Android Studio lo respetan solos. |
| `.vscode/extensions.json` | Al abrir el repo, VS Code ofrece instalar las extensiones necesarias. Es lo único de `.vscode/` que se sube. |

## `.github/`: automatización

| Archivo | Qué hace |
|---|---|
| `workflows/ci.yml` | En cada PR y cada push a `main`. Primero mira **qué partes existen y cuáles han cambiado**, y solo ejecuta esas: <br>• **server**: descarga vcpkg, compila con el preset `ci` y ejecuta `ctest`. Guarda las librerías compiladas en caché (la primera vez tarda ~20-30 min; luego unos pocos). <br>• **core**: `cargo fmt --check`, `cargo clippy -D warnings`, `cargo test`. <br>• **app**: `flutter analyze` y `flutter test`. <br>• **android**: solo al fusionar en `main`, genera un APK de prueba descargable desde la pestaña Actions (7 días). <br>Windows, macOS e iOS se compilan más adelante, solo con tags (`release.yml`, S9). |
| `workflows/pages.yml` | Cuando cambia `site/` en `main`, publica la web informativa en GitHub Pages. |
| `pull_request_template.md` | Al abrir un PR aparece ya escrito: qué cambia, historia, cómo probarlo y la checklist de «hecho». |
| `ISSUE_TEMPLATE/bug.md`, `tarea.md` | Formularios para reportar un error (plataforma, pasos, logs) o crear una tarea (historia, dueño, horas). Útiles con los probadores externos. |
| `CODEOWNERS` | Asigna revisor automáticamente según la carpeta tocada. **Hay que poner los usuarios de GitHub de Matías e Iker** y descomentar sus líneas. |

**Configurar una vez en GitHub** (Settings → Branches → regla para `main`): exigir PR, 1 aprobación,
CI en verde y prohibir push directo.

## `app/`: cliente Flutter

Una sola base de código Dart que se compila para las 6 plataformas.

- **Las carpetas nativas (`android/`, `ios/`, `windows/`, `linux/`, `macos/`, `web/`) y `pubspec.yaml` no están todavía**: las genera `flutter create` (pasos en `app/README.md`). Se suben al repo después de generarlas, porque ahí van los permisos, iconos y la configuración de firma.
- `flutter_rust_bridge.yaml`: le dice al generador que el núcleo está en `../core` y que el código Dart generado va a `lib/src/rust/`.
- `lib/core/`: lo que comparte toda la app.
  - `config/`: URL del servidor según el entorno.
  - `network/`: cliente HTTP y `RealtimeService`, que mantiene el WebSocket y se reconecta solo.
  - `router/`: rutas y redirección al login si no hay sesión.
  - `theme/`: colores y tipografía de Figma.
  - `storage/`: almacén seguro del sistema y la BD local cifrada.
  - `errors/`: errores comunes.
- `lib/features/`: una carpeta por épica (`auth`, `profile`, `contacts`, `chat`), y dentro de cada una tres capas:
  - `data/`: repositorios que hablan con el servidor, la BD local y Rust.
  - `domain/`: modelos puros (`Message`, `User`…), sin Flutter.
  - `presentation/`: blocs y pantallas.
  - Regla: **pantalla → bloc → repositorio**, nunca al revés. Así los blocs se prueban con repositorios falsos.
- `lib/src/rust/`: código generado. No se edita; se regenera con `flutter_rust_bridge_codegen generate`.
- `assets/models/`: aquí se descarga el modelo ONNX del clasificador. No se sube (pesa ~10 MB).
- `test/` e `integration_test/`: tests unitarios (rápidos, sin servidor) y de punta a punta (con Docker levantado).
- Los `.gitkeep` solo sirven para que Git guarde carpetas vacías; se borran cuando la carpeta tenga archivos.

## `core/`: núcleo Rust

La parte que hace el cifrado y la moderación, compilada como librería nativa para cada plataforma
(y a WebAssembly para la web). Ya compila y pasa `cargo fmt`, `cargo clippy -D warnings` y sus tests.

| Archivo | Qué es |
|---|---|
| `Cargo.toml` | Dependencias: flutter_rust_bridge (versión exacta, debe coincidir con la de Dart), vodozemac (Olm), chacha20poly1305 + sha2 + rand (archivos), tract-onnx + image (clasificador), thiserror, serde. `crate-type` genera librería dinámica (Android, Windows, Linux) y estática (iOS, macOS). |
| `Cargo.lock` | Versiones exactas de todas las dependencias. Se sube: así los tres compiláis lo mismo. |
| `src/lib.rs` | Raíz de la librería: declara los módulos. Tiene comentada la línea `mod frb_generated;`, que se activa tras generar el puente. |
| `src/error.rs` | `CoreError`: todos los errores posibles (descifrado fallido, contenido bloqueado…). Flutter los recibe como excepciones. |
| `src/api/` | **Lo único que ve Flutter.** <br>• `simple.rs`: `core_version()` y `sumar()`, para probar el puente en S1. <br>• `files.rs`: cifrar/descifrar archivos (ya funciona). <br>• `crypto.rs`: lista de funciones de Olm previstas para S5-S6. <br>• `moderation.rs`: lista de funciones del clasificador previstas para S8. |
| `src/crypto/file_cipher.rs` | **Ya implementado y probado**: clave aleatoria por archivo, XChaCha20-Poly1305 y SHA-256. Tests: ida y vuelta, un byte alterado falla, hash distinto falla. Sirve de ejemplo de cómo escribir el resto. |
| `src/crypto/olm.rs` | Envoltorio de vodozemac (S5-S6). Ahora contiene los pasos a seguir. |
| `src/moderation/` | Clasificador +18 con tract-onnx (S8). Ahora contiene el flujo a seguir. |
| `tests/`, `test_data/` | Tests de integración (Olm de ida y vuelta con 1.000 mensajes, clasificador con imágenes fijas) e imágenes de prueba seguras. |

## `server/`: servidor C++

| Archivo | Qué es |
|---|---|
| `CMakeLists.txt` | Define tres cosas: `vapor_lib` (todo el código menos `main.cpp`), `vapor_server` (el ejecutable) y `vapor_tests` (GoogleTest). Así los tests usan el mismo código que el servidor. Activa avisos estrictos y, en Debug, **AddressSanitizer + UBSan** para detectar fugas y accesos inválidos. Las librerías Boost, OpenSSL, libsodium y jwt-cpp están comentadas: se descomentan cuando se empiezan a usar. |
| `CMakePresets.json` | Configuraciones listas: `cmake --preset debug`, `release` o `ci`. Usan Ninja y el toolchain de vcpkg (`VCPKG_ROOT`). VS Code (CMake Tools) y CLion las detectan solas. |
| `vcpkg.json` | Librerías que vcpkg descarga y compila: Boost (Asio, Beast, JSON, MySQL), OpenSSL, libsodium, jwt-cpp, spdlog y GoogleTest. `builtin-baseline` fija las versiones (Boost 1.92, spdlog 1.17…) para que los tres tengáis las mismas. |
| `.clang-format`, `.clang-tidy` | Formato automático y análisis estático (errores típicos, C++ moderno, rendimiento). |
| `src/main.cpp` | Punto de entrada. Ahora solo carga la configuración y la muestra; en S1-S2 se añade el `io_context`, Ctrl+C, el listener HTTP/WebSocket y el pool de MySQL. |
| `src/config/` | **Ya funciona**: lee la configuración de variables de entorno y valida puertos y el secreto JWT (mínimo 32 caracteres; si falta, el servidor no arranca). |
| `src/http/` | Listener, sesión HTTP de Beast, router `(método, ruta) → handler` y respuestas de error comunes. |
| `src/ws/` | Sesión WebSocket, `SessionManager` (qué usuario tiene qué conexiones), mensajes `msg.*`. |
| `src/db/` | Pool de conexiones Boost.MySQL y un repositorio por área (`UserRepository`…). Siempre statements preparados. |
| `src/auth/` | Argon2id, JWT de 15 min, refresh tokens de 30 días, límite de intentos de login. |
| `src/files/` | `POST /files` y `GET /files/{id}` con SeaweedFS. El servidor nunca descifra nada. |
| `src/mail/` | Correo de recuperación de contraseña por SMTP (Mailpit en desarrollo). |
| `src/util/` | UUID, base64, SHA-256, fechas… |
| `migrations/001_init.sql` | **Las 11 tablas del MVP** del modelo de datos v2, en su orden: `rol` (con sus 4 filas), `usuario`, `refresh_token`, `reset_token`, `dispositivo`, `prekey`, `amistad`, `conversacion`, `participante`, `mensaje_cifrado`, `archivo_cifrado`, más `migracion` para saber qué se ha aplicado. Incluye claves foráneas, `UNIQUE` y `CHECK` (orden de `amistad`, `kind` 0/1, tamaño ≤ 10 MB). Probada en MySQL 8. |
| `tests/config_test.cpp` | Primer test: puertos válidos y no válidos. Plantilla para el resto. |

**Regla de migraciones:** una migración aplicada no se edita nunca. Para cambiar algo, `002_….sql` con `ALTER TABLE`.

## `infra/`: servicios e infraestructura

| Archivo | Qué es |
|---|---|
| `docker-compose.yml` | Levanta **MySQL 8.4**, **SeaweedFS** (S3 para los blobs cifrados) y **Mailpit** (bandeja de correos falsa en `localhost:8025`). Los puertos solo escuchan en `127.0.0.1` (nadie de tu red entra). MySQL ejecuta solas las migraciones la primera vez. **Caddy** está en el perfil `demo`: solo arranca en el servidor de pruebas con `--profile demo`. El servidor C++ no va en Docker durante el desarrollo, para poder depurarlo. |
| `caddy/Caddyfile` | En el servidor de pruebas y en la demo: HTTPS con certificado automático y **solo TLS 1.3**. Reenvía la API y `/ws` al servidor C++ y sirve la versión web de la app con las cabeceras COOP/COEP que necesita WebAssembly. |
| `seed/seed_dev.sql` | 4 usuarios de prueba y dos relaciones de amistad. Solo desarrollo. |
| `scripts/dev-up.sh`, `dev-up.ps1` | Crean `.env` si no existe y levantan los servicios (Linux/macOS y Windows). |
| `scripts/backup_mysql.sh` | Copia comprimida de MySQL; guarda las 14 últimas. Para programar a diario en el servidor de pruebas. |
| `scripts/download_model.sh` | Descarga el modelo ONNX y comprueba su SHA-256. Falta poner la URL (Iker, S8). |
| `k6/` | Prueba de carga de S8: 500 WebSockets durante 5 minutos. |

## `docs/`: documentación

| Carpeta / archivo | Qué es |
|---|---|
| `protocolo.md` | **Fuente de verdad del contrato** entre app y servidor: rutas REST, mensajes WebSocket y formato del contenido cifrado. Se cambia solo por PR revisado por cliente y servidor. Falta detallar el JSON exacto de HO1 antes de S3. |
| `decisiones/` | Un archivo corto por decisión técnica (contexto, decisión, alternativas, consecuencias). Ya están: vodozemac, un dispositivo por cuenta y Caddy para TLS. En abril, la memoria se escribe casi sola a partir de aquí. |
| `actas/` | Una por reunión o demo, con plantilla. Incluye las horas reales del sprint para el Excel. |
| `modelo-datos/` | Diccionario de datos (xlsx) y diagrama E-R (falta añadir el `.drawio`). |
| `pruebas/` | Resultados de carga, seguridad, clasificador y probadores externos. |
| `memoria/` | Memoria final y presentación (S12). |

## `site/`: página informativa

Web estática (HTML/CSS) con qué es Vapor, descargas por plataforma, FAQ y privacidad. Se publica gratis
en GitHub Pages. **No es la versión web de la app**, que sale de `app/` con `flutter build web`.
