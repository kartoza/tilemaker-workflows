#!/usr/bin/env bash
source ./common.sh

ensure_geodata

PBF_RAW="${DOWNLOAD_DIR}/planet-latest.osm.pbf"
PBF_OPT="${DOWNLOAD_DIR}/planet-latest-optimized.osm.pbf"

if test -f "$PBF_OPT"; then
  echo "Optimised planet PBF already exists, skipping download..."
else
  if test -f "$PBF_RAW"; then
    echo "Raw planet PBF already exists, skipping download..."
  else
    echo "Downloading planet-latest.osm.pbf..."
    curl -L -o "$PBF_RAW" https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
  fi
  echo "Optimising with osmium..."
  time osmium cat -f pbf "$PBF_RAW" -o "$PBF_OPT"
fi

detect_store_strategy

echo "Processing planet..."
time tilemaker \
  "${TILEMAKER_COMMON_ARGS[@]}" \
  "${STORE_ARGS[@]}" \
  "$PBF_OPT" "${OUTPUT_DIR}/planet.mbtiles"

echo "Done! Output: ${OUTPUT_DIR}/planet.mbtiles"
