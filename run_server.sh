#!/usr/bin/env bash

SERVE_DIR="${1:-output}"

if [ ! -d "$SERVE_DIR" ] || [ -z "$(find "$SERVE_DIR" -name '*.mbtiles' -print -quit 2>/dev/null)" ]; then
  echo "No .mbtiles files found in ${SERVE_DIR}/"
  echo "Run a processing workflow first, e.g.: nix run .#processMalta"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIEWER_PORT=8081

echo "Serving tiles from ${SERVE_DIR}/..."
echo ""
echo "  TileJSON:  http://localhost:8000/services/"
echo "  Fonts:     http://localhost:8001/fonts/"
echo "  Viewer:    http://localhost:${VIEWER_PORT}/viewer.html"
echo ""

# Start a simple HTTP server for viewer.html in the background
python3 -m http.server "$VIEWER_PORT" --directory "$SCRIPT_DIR" &
VIEWER_PID=$!

# Start a font server on port 8001
FONT_PORT=8001
python3 -m http.server "$FONT_PORT" --directory "$SCRIPT_DIR" &
FONT_PID=$!

# Ensure both servers are stopped when this script exits
trap 'kill $VIEWER_PID $FONT_PID 2>/dev/null' EXIT

# Open the viewer in the default browser
if command -v xdg-open &>/dev/null; then
  xdg-open "http://localhost:${VIEWER_PORT}/viewer.html" &
elif command -v open &>/dev/null; then
  open "http://localhost:${VIEWER_PORT}/viewer.html" &
fi

mbtileserver --basemap-style-url "https://raw.githubusercontent.com/openmaptiles/osm-bright-gl-style/master/style.json" -d "$SERVE_DIR"
