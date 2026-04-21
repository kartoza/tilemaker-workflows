#!/usr/bin/env bash

# Natural Earth urban areas
if test -f "landcover/ne_10m_urban_areas/ne_10m_urban_areas.shp"; then
  echo "ne_10m_urban_areas already exists."
else
  echo "Downloading ne_10m_urban_areas..."
  mkdir -p landcover/ne_10m_urban_areas
  cd landcover/ne_10m_urban_areas || exit
  curl -OL https://naciscdn.org/naturalearth/10m/cultural/ne_10m_urban_areas.zip
  unzip -o ne_10m_urban_areas.zip
  rm ne_10m_urban_areas.zip
  cd ../../ || exit
fi

# Antarctic ice shelves
if test -f "landcover/ne_10m_antarctic_ice_shelves_polys/ne_10m_antarctic_ice_shelves_polys.shp"; then
  echo "ne_10m_antarctic_ice_shelves_polys already exists."
else
  echo "Downloading ne_10m_antarctic_ice_shelves_polys..."
  mkdir -p landcover/ne_10m_antarctic_ice_shelves_polys
  cd landcover/ne_10m_antarctic_ice_shelves_polys || exit
  curl -OL https://naciscdn.org/naturalearth/10m/physical/ne_10m_antarctic_ice_shelves_polys.zip
  unzip -o ne_10m_antarctic_ice_shelves_polys.zip
  rm ne_10m_antarctic_ice_shelves_polys.zip
  cd ../../ || exit
fi

# Glaciated areas
if test -f "landcover/ne_10m_glaciated_areas/ne_10m_glaciated_areas.shp"; then
  echo "ne_10m_glaciated_areas already exists."
else
  echo "Downloading ne_10m_glaciated_areas..."
  mkdir -p landcover/ne_10m_glaciated_areas
  cd landcover/ne_10m_glaciated_areas || exit
  curl -OL https://naciscdn.org/naturalearth/10m/physical/ne_10m_glaciated_areas.zip
  unzip -o ne_10m_glaciated_areas.zip
  rm ne_10m_glaciated_areas.zip
  cd ../../ || exit
fi

# OSM water polygons (coastlines)
# The zip contains a subdirectory — move files up to match config.json path
if test -f "coastline/water_polygons.shp"; then
  echo "coastline/water_polygons.shp already exists."
else
  echo "Downloading water-polygons-split-4326..."
  mkdir -p coastline/
  cd coastline/ || exit
  curl -OL https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip
  unzip -o water-polygons-split-4326.zip
  mv water-polygons-split-4326/* .
  rmdir water-polygons-split-4326
  rm water-polygons-split-4326.zip
  cd ../ || exit
fi
