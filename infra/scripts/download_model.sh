#!/usr/bin/env bash
# Descarga el modelo ONNX del clasificador +18 a app/assets/models/ (no se sube al repo: ~10 MB).
# TODO (Iker, S8): poner la URL definitiva del modelo convertido y su SHA-256.
set -euo pipefail

MODEL_URL="${MODEL_URL:-PON_AQUI_LA_URL_DEL_MODELO}"
MODEL_SHA256="${MODEL_SHA256:-PON_AQUI_EL_SHA256}"
DEST="$(dirname "$0")/../../app/assets/models/nsfw_mobilenet_v2.onnx"

if [[ "$MODEL_URL" == PON_AQUI* ]]; then
  echo "Falta la URL del modelo (ver la sección de moderación de la guía)." >&2
  exit 1
fi

mkdir -p "$(dirname "$DEST")"
curl -fL "$MODEL_URL" -o "$DEST"
echo "$MODEL_SHA256  $DEST" | sha256sum -c -
echo "Modelo guardado en $DEST"