//! API de cifrado de mensajes para Flutter (HO29). Se implementa en S5-S6.
//!
//! Funciones previstas (ver la guía del equipo, sección «Cifrado y moderación»):
//!
//! ```text
//! crypto_init(pickle_key, saved)      -> CryptoState
//! public_keys(&state)                 -> DeviceKeys   (identidad + one-time keys sin publicar)
//! mark_keys_published(&state)
//! encrypt_for(&state, peer, peer_identity, peer_otk, plaintext) -> Encrypted { kind, body }
//! decrypt_from(&state, peer, peer_identity, kind, body)         -> String
//! export_state(&state)                -> String       (pickle cifrado para guardarlo)
//! ```
//!
//! La lógica de verdad vive en `crate::crypto::olm`; aquí solo se adaptan tipos.
