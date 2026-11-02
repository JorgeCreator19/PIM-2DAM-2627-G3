//! Envoltorio de vodozemac (Olm) para los chats 1:1 (HO29, S5-S6).
//!
//! Pasos a implementar (detalle en la guía del equipo):
//! 1. Crear `vodozemac::olm::Account` y generar 50 one-time keys.
//! 2. Sesión de salida con la identidad + una one-time key del otro -> mensaje PreKey (kind 0).
//! 3. Sesión de entrada a partir del primer mensaje recibido.
//! 4. Guardar cuenta y sesiones como pickle cifrado con la clave de 32 bytes del almacén seguro.
//!
//! Primer ejercicio (S1-S2): un test en `tests/olm_roundtrip.rs` en el que Alice y Bob
//! se mandan un mensaje usando solo vodozemac.
