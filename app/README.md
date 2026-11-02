# app/ · Cliente Flutter de Vapor

Una sola base de código para Android, iOS, web, Windows, macOS y Linux.
Dueños: **Matías** (interfaz, `lib/`), **Iker** (móvil y puente con Rust), **Jorge** (escritorio).

## Crear el proyecto Flutter (UNA sola vez, lo hace una persona en S1)

Las carpetas `lib/` y `assets/` ya existen con la estructura acordada. Faltan las carpetas
nativas (`android/`, `ios/`, `windows/`…) y `pubspec.yaml`, que las genera Flutter:

```bash
cd app
flutter create --project-name vapor --org es.fruitsalad --platforms=android,ios,web,windows,macos,linux .
```

`flutter create .` no borra lo que ya hay en `lib/`: solo añade lo que falta.

Después, añadir los paquetes acordados:

```bash
flutter pub add flutter_bloc equatable go_router dio web_socket_channel flutter_secure_storage drift sqlcipher_flutter_libs image_picker path_provider
flutter pub add --dev bloc_test mocktail drift_dev build_runner
```

## Conectar el núcleo Rust (Iker, S1-S2)

Requisitos: Rust estable (`rustup`), y la MISMA versión del generador que la de `core/Cargo.toml`:

```bash
cargo install flutter_rust_bridge_codegen --version 2.13.0
cd app
flutter_rust_bridge_codegen integrate
```

`integrate` crea un crate de ejemplo en `app/rust/` y la carpeta `app/rust_builder/`
(compila Rust en cada plataforma). Como nuestro núcleo vive en `../core`:

1. Borrar `app/rust/` (el crate de ejemplo).
2. En `app/rust_builder/`, buscar las rutas que apuntan al crate de ejemplo y cambiarlas:
   ```bash
   grep -rn "\.\./\.\./rust" rust_builder
   ```
   Cada `../../rust` pasa a `../../../core`, y el nombre de librería (`rust_lib_vapor`) pasa a `vapor_core`.
3. Comprobar que `flutter_rust_bridge.yaml` es el de este repo (rust_root: ../core/).
4. `flutter_rust_bridge_codegen generate` y descomentar `mod frb_generated;` en `core/src/lib.rs`.
5. Prueba de S1: un botón que llama a `sumar(2, 3)` y a `coreVersion()` en Android y en escritorio.

Si cambia algo en `core/src/api/`, hay que volver a ejecutar `flutter_rust_bridge_codegen generate`.

## Estructura de `lib/`

```
lib/
├── main.dart          arranque: inicializa Rust, servicios y abre la app
├── app.dart           MaterialApp.router con tema y rutas
├── core/              lo que comparten todas las pantallas
│   ├── config/        URL del servidor por entorno (dev, demo)
│   ├── network/       cliente HTTP (dio) y RealtimeService (WebSocket con reconexión)
│   ├── router/        rutas con go_router y redirección si no hay sesión
│   ├── theme/         colores, tipografía y ThemeData (copiados de Figma)
│   ├── storage/       almacén seguro (tokens, claves) y BD local cifrada (drift + SQLCipher)
│   └── errors/        tipos de error comunes y mensajes para el usuario
├── features/          una carpeta por épica del MVP
│   ├── auth/          HO1, HO12   registro, login, recuperar contraseña
│   ├── profile/       HO11        perfil y edición
│   ├── contacts/      HO3, HO17   buscar, amigos, solicitudes, bloquear
│   └── chat/          HO4, HO22, HO29, HO31, HO32
│       ├── data/          repositorios: hablan con servidor, BD local y Rust
│       ├── domain/        modelos (Message, Conversation…)
│       └── presentation/  blocs y pantallas
└── src/rust/          GENERADO por flutter_rust_bridge (no tocar)
```

Regla de capas: **pantallas → blocs → repositorios → (servidor | BD local | Rust)**. Nunca al revés.

## Comandos habituales

```bash
flutter run -d windows        # o linux, macos, chrome, o el id de un móvil (flutter devices)
flutter analyze
flutter test
flutter test integration_test # necesita los servicios de infra/ levantados
```
