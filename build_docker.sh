#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "  Building Docker image via Nix..."
echo ""

# Check fonts exist
if [ ! -d "fonts" ] || [ -z "$(find fonts -name '*.pbf' -print -quit 2>/dev/null)" ]; then
  echo "  Error: fonts/ directory not found or empty."
  echo "  Run 'make get-data' first to download fonts."
  exit 1
fi

# Build Nix base image (use result link to handle chroot nix stores)
RESULT_LINK=".docker-build-result"
nix --extra-experimental-features 'nix-command flakes' build .#dockerImage -o "$RESULT_LINK"

# Resolve the actual file path (handles chroot nix stores where /nix/store is under ~/.local/share/nix/root)
NIX_STORE_PATH=$(readlink "$RESULT_LINK")
if [ -f "$NIX_STORE_PATH" ]; then
  IMAGE_PATH="$NIX_STORE_PATH"
elif [ -f "$HOME/.local/share/nix/root${NIX_STORE_PATH}" ]; then
  IMAGE_PATH="$HOME/.local/share/nix/root${NIX_STORE_PATH}"
else
  echo "  Error: Cannot find built image at $NIX_STORE_PATH"
  rm -f "$RESULT_LINK"
  exit 1
fi
rm -f "$RESULT_LINK"

BASE_SIZE=$(du -sh "$IMAGE_PATH" | awk '{print $1}')
echo "  Loading Nix base image ($BASE_SIZE)..."
docker load < "$IMAGE_PATH"

# Layer fonts on top via Dockerfile
FONT_COUNT=$(find fonts -type d -mindepth 1 -maxdepth 1 | wc -l)
FONT_SIZE=$(du -sh fonts | awk '{print $1}')
echo "  Layering $FONT_COUNT font families ($FONT_SIZE) into final image..."
docker build -t tilemaker-server:latest -f Dockerfile .

# Gather style and font lists
STYLE_COUNT=$(find styles -name '*.json' | wc -l)
STYLE_LIST=$(find styles -name '*.json' -exec basename {} .json \; | sort | paste -sd ', ')
FONT_LIST=$(find fonts -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

# Print stats
IMAGE_SIZE=$(docker image inspect tilemaker-server:latest --format '{{.Size}}' | awk '{printf "%.1f MB", $1/1024/1024}')
LAYER_COUNT=$(docker image inspect tilemaker-server:latest --format '{{len .RootFS.Layers}}')
CREATED=$(docker image inspect tilemaker-server:latest --format '{{.Created}}' | cut -c1-19)
IMAGE_ID=$(docker image inspect tilemaker-server:latest --format '{{.Id}}' | cut -c8-19)
EXPOSED=$(docker image inspect tilemaker-server:latest --format '{{range $p, $_ := .Config.ExposedPorts}}{{$p}} {{end}}')

echo ""
echo "  +---------------------------------------------------------+"
echo "  |              tilemaker-server:latest                     |"
echo "  +---------------------------------------------------------+"
printf "  |  %-14s %-40s |\n" "Status:" "Built successfully"
printf "  |  %-14s %-40s |\n" "Image ID:" "$IMAGE_ID"
printf "  |  %-14s %-40s |\n" "Nix base:" "$BASE_SIZE"
printf "  |  %-14s %-40s |\n" "Total size:" "$IMAGE_SIZE"
printf "  |  %-14s %-40s |\n" "Layers:" "$LAYER_COUNT"
printf "  |  %-14s %-40s |\n" "Created:" "$CREATED"
printf "  |  %-14s %-40s |\n" "Ports:" "$EXPOSED"
echo "  +---------------------------------------------------------+"
echo ""
echo "  Styles ($STYLE_COUNT):"
echo "    $STYLE_LIST"
echo ""
echo "  Fonts ($FONT_COUNT families, $FONT_SIZE):"
echo "$FONT_LIST" | while read -r font; do
  echo "    - $font"
done
echo ""
echo "  +---------------------------------------------------------+"
echo "  Run with: docker compose up"
echo "  +---------------------------------------------------------+"
echo ""
