#!/usr/bin/env bash
if test -f "landcover/ne_10m_urban_areas/ne_10m_urban_areas.shp"; then
  echo "ne_10m_urban_areas file exists."
else
  echo "ne_10m_urban_areas does not exist."
  mkdir -p landcover/ne_10m_urban_areas
  cd landcover/ne_10m_urban_areas
  curl -OL https://naciscdn.org/naturalearth/10m/cultural/ne_10m_urban_areas.zip
  unzip ne_10m_urban_areas.zip
  rm ne_10m_urban_areas.zip
  cd ../../
fi

if test -f "landcover//.shp"; then
  echo "file exists."
else
  echo "does not exist."
  mkdir -p landcover/
  cd landcover/
  curl -OL 
  unzip .zip
  rm .zip
  cd ../../
fi

if test -f "landcover//.shp"; then
  echo "file exists."
else
  echo "does not exist."
  mkdir -p landcover/
  cd landcover/
  curl -OL 
  unzip .zip
  rm .zip
  cd ../../
fi

if test -f "coastline/water-polygons-split-4326.shp"; then
  echo "coastline/water-polygons-split-4326.shp exists."
else
  echo "coastline/water-polygons-split-4326.shp does not exist."
  mkdir -p coastline/
  cd coastline/
  curl -OL https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip
  unzip water-polygons-split-4326.zip
  rm water-polygons-split-4326.zip
  cd ../
fi

#curl -OL https://naciscdn.org/naturalearth/10m/physical/ne_10m_antarctic_ice_shelves_polys.zip
#curl -OL https://naciscdn.org/naturalearth/10m/physical/ne_10m_glaciated_areas.zip
#mkdir ne_10m_antarctic_ice_shelves_polys
#mkdir ne_10m_glaciated_areas
#cd ../ne_10m_glaciated_areas/
#unzip ../../ne_10m_antarctic_ice_shelves_polys.zip
#cd ../ne_10m_antarctic_ice_shelves_polys
#unzip ../../ne_10m_antarctic_ice_shelves_polys.zip
#cd ..
#cd ..
