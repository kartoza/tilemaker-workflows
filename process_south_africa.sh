#!/usr/bin/env bash

# shellcheck disable=SC1091
source ./common.sh

ensure_geodata

PBF="${DOWNLOAD_DIR}/south-africa-latest.osm.pbf"

if ! test -f "$PBF"; then
  echo "Downloading south-africa-latest.osm.pbf..."
  curl -L -o "$PBF" https://download.geofabrik.de/africa/south-africa-latest.osm.pbf
fi

echo "Processing South Africa..."
time tilemaker \
  --config config.json \
  --process process.lua \
  --fast \
  --no-compress-ways \
  --no-compress-nodes \
  "$PBF" "${OUTPUT_DIR}/south-africa.mbtiles"

echo "Done! Output: ${OUTPUT_DIR}/south-africa.mbtiles"
