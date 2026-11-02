//! Cifrado de archivos: clave aleatoria por archivo + XChaCha20-Poly1305 + SHA-256.
//! Formato del blob: [nonce de 24 bytes][texto cifrado + etiqueta de 16 bytes].

use chacha20poly1305::{
    XChaCha20Poly1305, XNonce,
    aead::{Aead, KeyInit},
};
use rand::RngExt;
use sha2::{Digest, Sha256};

use crate::error::{CoreError, CoreResult};

const KEY_LEN: usize = 32;
const NONCE_LEN: usize = 24;

/// Devuelve (blob, clave, sha256 del blob).
pub fn encrypt(data: &[u8]) -> CoreResult<(Vec<u8>, Vec<u8>, Vec<u8>)> {
    let mut rng = rand::rng();
    let key: [u8; KEY_LEN] = rng.random();
    let nonce: [u8; NONCE_LEN] = rng.random();

    let cipher = XChaCha20Poly1305::new_from_slice(&key).map_err(|_| CoreError::InvalidKey)?;
    let ciphertext = cipher
        .encrypt(&XNonce::from(nonce), data)
        .map_err(|e| CoreError::Encrypt(e.to_string()))?;

    let mut blob = Vec::with_capacity(NONCE_LEN + ciphertext.len());
    blob.extend_from_slice(&nonce);
    blob.extend_from_slice(&ciphertext);

    let hash = Sha256::digest(&blob).to_vec();
    Ok((blob, key.to_vec(), hash))
}

pub fn decrypt(blob: &[u8], key: &[u8], expected_sha256: &[u8]) -> CoreResult<Vec<u8>> {
    if Sha256::digest(blob).as_slice() != expected_sha256 {
        return Err(CoreError::Decrypt);
    }
    if blob.len() < NONCE_LEN {
        return Err(CoreError::Decrypt);
    }
    let (nonce, ciphertext) = blob.split_at(NONCE_LEN);
    let cipher = XChaCha20Poly1305::new_from_slice(key).map_err(|_| CoreError::InvalidKey)?;
    let nonce = XNonce::try_from(nonce).map_err(|_| CoreError::Decrypt)?;
    cipher
        .decrypt(&nonce, ciphertext)
        .map_err(|_| CoreError::Decrypt)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ida_y_vuelta() {
        let data = b"captura de la partida".to_vec();
        let (blob, key, hash) = encrypt(&data).expect("cifra");
        assert_eq!(decrypt(&blob, &key, &hash).expect("descifra"), data);
    }

    #[test]
    fn un_byte_cambiado_falla() {
        let (mut blob, key, _) = encrypt(b"hola").expect("cifra");
        let last = blob.len() - 1;
        blob[last] ^= 1;
        let hash = Sha256::digest(&blob).to_vec(); // aunque el hash cuadre, la etiqueta no
        assert!(decrypt(&blob, &key, &hash).is_err());
    }

    #[test]
    fn hash_distinto_falla() {
        let (blob, key, _) = encrypt(b"hola").expect("cifra");
        assert!(decrypt(&blob, &key, &[0u8; 32]).is_err());
    }
}
