//! Núcleo de Vapor (dueño: Iker).
//!
//! - `api/`        -> lo ÚNICO que ve Flutter (flutter_rust_bridge genera el código a partir de aquí).
//! - `crypto/`     -> cifrado de mensajes (vodozemac) y de archivos.
//! - `moderation/` -> clasificador de imágenes +18.
//!
//! Regla: nada de `unwrap()` fuera de los tests; todo devuelve `Result<_, CoreError>`.

pub mod api;
pub mod crypto;
pub mod error;
pub mod moderation;

// Descomenta esta línea después de ejecutar `flutter_rust_bridge_codegen generate`
// la primera vez (el archivo lo crea el generador):
// mod frb_generated;

pub use error::CoreError;
