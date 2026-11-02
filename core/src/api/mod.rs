//! API pública para Flutter. Solo tipos simples: String, Vec<u8>, números, structs planos.
//! El estado (cuenta Olm, sesiones) va dentro de objetos opacos.

pub mod crypto;
pub mod files;
pub mod moderation;
pub mod simple;
