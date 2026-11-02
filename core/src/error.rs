//! Errores del núcleo. Flutter los recibe como excepciones con este mensaje.

use thiserror::Error;

#[derive(Debug, Error)]
pub enum CoreError {
    #[error("no se pudo cifrar: {0}")]
    Encrypt(String),

    #[error("no se pudo descifrar (mensaje alterado o clave incorrecta)")]
    Decrypt,

    #[error("clave con formato incorrecto")]
    InvalidKey,

    #[error("el contenido no está permitido")]
    Blocked,

    #[error("la imagen no es válida: {0}")]
    InvalidImage(String),

    #[error("error interno: {0}")]
    Internal(String),
}

pub type CoreResult<T> = Result<T, CoreError>;