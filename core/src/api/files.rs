//! API de cifrado de archivos para Flutter (HO22).

use crate::crypto::file_cipher;
use crate::error::CoreResult;

/// Resultado de cifrar un archivo: lo que se sube y lo que va dentro del mensaje cifrado.
pub struct EncryptedFile {
    /// Bytes a subir a SeaweedFS (nonce + texto cifrado).
    pub blob: Vec<u8>,
    /// Clave de 32 bytes del archivo. Viaja SOLO dentro del mensaje cifrado con Olm.
    pub key: Vec<u8>,
    /// SHA-256 del blob, para comprobar que nadie lo ha cambiado.
    pub sha256: Vec<u8>,
}

pub fn encrypt_file(data: Vec<u8>) -> CoreResult<EncryptedFile> {
    let (blob, key, sha256) = file_cipher::encrypt(&data)?;
    Ok(EncryptedFile { blob, key, sha256 })
}

pub fn decrypt_file(blob: Vec<u8>, key: Vec<u8>, sha256: Vec<u8>) -> CoreResult<Vec<u8>> {
    file_cipher::decrypt(&blob, &key, &sha256)
}
