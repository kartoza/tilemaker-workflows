#!/usr/bin/env bash

SERVE_DIR="${1:-output}"

if [ ! -d "$SERVE_DIR" ] || [ -z "$(find "$SERVE_DIR" -name '*.mbtiles' -print -quit 2>/dev/null)" ]; then
  echo "No .mbtiles files found in ${SERVE_DIR}/"
  echo "Run a processing workflow first, e.g.: nix run .#processMalta"
  exit 1
fi

echo "Serving tiles from ${SERVE_DIR}/..."
mbtileserver --basemap-style-url "https://raw.githubusercontent.com/openmaptiles/osm-bright-gl-style/master/style.json" -d "$SERVE_DIR"
