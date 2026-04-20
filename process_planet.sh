#!/usr/bin/env bash

./get_data.sh

if test -f "planet-latest-optimized.osm.pbf"; then
  echo "planet-latest-optimized.osm.pbf already exists, skipping download..."
else
  echo "Downloading planet-latest.osm.pbf..."
  curl -OL https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
  echo "Optimising with osmium..."
  time osmium cat -f pbf planet-latest.osm.pbf -o planet-latest-optimized.osm.pbf
fi

# Check available RAM to decide between in-memory or disk-backed processing
# Planet processing needs ~100GB RAM to run entirely in memory
available_ram_gb=$(awk '/MemAvailable/ {printf "%d", $2/1024/1024}' /proc/meminfo)
echo "Available RAM: ${available_ram_gb}GB"

store_args=()
if [ "$available_ram_gb" -lt 100 ]; then
  echo "Insufficient RAM for in-memory processing (need ~100GB, have ${available_ram_gb}GB)"
  echo "Using disk-backed store at ${PWD}/work"
  mkdir -p work
  store_args=(--store "${PWD}/work")
else
  echo "Sufficient RAM available — processing entirely in memory"
fi

time tilemaker \
  --config config.json \
  --process process.lua \
  --fast \
  --no-compress-ways \
  --no-compress-nodes \
  "${store_args[@]}" \
  planet-latest-optimized.osm.pbf planet.mbtiles
