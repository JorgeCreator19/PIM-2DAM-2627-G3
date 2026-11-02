//! API del clasificador +18 para Flutter (HO31). Se implementa en S8.
//!
//! ```text
//! moderation_load(model_bytes)            -> se llama una vez al arrancar
//! check_image(image_bytes) -> Result<(), CoreError::Blocked>
//! ```
//!
//! Se llama SIEMPRE antes de `encrypt_file`; si devuelve `Blocked`, no se sube nada.
