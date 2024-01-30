#!/usr/bin/env bash

if test -f "planet-latest-optimised.osm.pbf"; then
  echo "planet.pbf file exists...."
else
  echo "planet.pbf does not exist."
  curl -OL https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
  time osmium cat -f pbf planet-latest.osm.pbf -o planet-latest-optimized.osm.pbf
fi

time tilemaker \
  --config config.json \
  --process process.lua \
  --fast \
  --no-compress-ways \
  --no-compress-nodes \
  planet-latest-optimized.osm.pbf planet.mbtiles
