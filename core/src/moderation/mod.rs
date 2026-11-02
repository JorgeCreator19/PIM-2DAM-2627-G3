//! Clasificador +18 con tract-onnx (HO31, S8).
//!
//! Flujo: decodificar (crate `image`) -> redimensionar a 224×224 -> normalizar ->
//! ejecutar el modelo -> sumar `porn + hentai` -> comparar con el umbral.
//! El modelo (`nsfw_mobilenet_v2.onnx`) NO está en el repo: lo descarga
//! `infra/scripts/download_model.sh` a `app/assets/models/`.
