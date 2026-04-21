#!/usr/bin/env bash
# shellcheck disable=SC1091
source ./common.sh

ensure_geodata

PBF="${DOWNLOAD_DIR}/malta-latest.osm.pbf"

if test -f "$PBF"; then
  echo "Malta PBF already exists, skipping download..."
else
  echo "Downloading Malta extract..."
  curl -L -o "$PBF" https://download.geofabrik.de/europe/malta-latest.osm.pbf
fi

echo "Processing Malta..."
time tilemaker \
  "${TILEMAKER_COMMON_ARGS[@]}" \
  "$PBF" "${OUTPUT_DIR}/malta.mbtiles"

echo "Done! Output: ${OUTPUT_DIR}/malta.mbtiles"
