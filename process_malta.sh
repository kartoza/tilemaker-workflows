#!/usr/bin/env bash

curl -OL https://download.geofabrik.de/europe/malta-latest.osm.pbf
time tilemaker \
  --config config.json \
  --process process.lua \
  --fast \
  --no-compress-ways \
  --no-compress-nodes \
  malta-latest.osm.pbf malta.mbtiles
