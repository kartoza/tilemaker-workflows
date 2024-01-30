#!/usr/bin/env bash

if test -f "planet-latest.osm.pbf"; then
  echo "planet.pbf file exists...."
else
  echo "planet.pbf not exist."
  curl -OL https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
fi

time tilemaker \
  --config config.json \
  --process process.lua \
  --fast \
  --no-compress-ways \
  --no-compress-nodes \
  planet-latest.osm.pbf planet.mbtiles
