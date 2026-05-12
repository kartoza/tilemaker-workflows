#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-/data}"

if [ ! -d "$DATA_DIR" ] || [ -z "$(find "$DATA_DIR" -name '*.mbtiles' -print -quit 2>/dev/null)" ]; then
  echo "No .mbtiles files found in ${DATA_DIR}/"
  echo "Bind-mount a directory containing .mbtiles files to /data"
  exit 1
fi

echo ""
echo "  Tilemaker Server"
echo "  ================"
echo ""
echo "  Viewer:    http://localhost/viewer.html"
echo "  TileJSON:  http://localhost/services/"
echo "  Styles:    http://localhost/styles/"
echo "  Fonts:     http://localhost/fonts/"
echo ""
echo "  Serving tiles from ${DATA_DIR}/..."
echo ""

# Start mbtileserver in background on internal port 8000
mbtileserver \
  --port 8000 \
  --basemap-style-url "https://raw.githubusercontent.com/openmaptiles/osm-bright-gl-style/master/style.json" \
  -d "$DATA_DIR" &

# Run nginx in foreground
exec nginx -c /etc/nginx/nginx.conf
