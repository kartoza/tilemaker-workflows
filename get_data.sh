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

# Map viewer fonts (Noto Sans from demotiles, cursive from Google Fonts via fontnik)
if test -f "fonts/Noto Sans Regular/0-255.pbf"; then
  echo "Viewer fonts already exist."
else
  echo "Downloading viewer font glyphs..."
  for font in "Noto Sans Regular" "Noto Sans Bold" "Noto Sans Italic"; do
    mkdir -p "fonts/${font}"
    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${font}'))")
    for start in $(seq 0 256 65280); do
      end=$((start + 255))
      curl -sf "https://demotiles.maplibre.org/font/${encoded}/${start}-${end}.pbf" \
        -o "fonts/${font}/${start}-${end}.pbf" 2>/dev/null || rm -f "fonts/${font}/${start}-${end}.pbf"
    done
    echo "  Downloaded ${font}"
  done

  # Generate cursive fonts from Google Fonts TTFs using fontnik
  if command -v npx &>/dev/null; then
    for fontinfo in "dancingscript/DancingScript%5Bwght%5D.ttf:Dancing Script Regular" \
                    "kalam/Kalam-Regular.ttf:Kalam Regular" \
                    "kalam/Kalam-Bold.ttf:Kalam Bold"; do
      urlpath="${fontinfo%%:*}"
      fontname="${fontinfo##*:}"
      ttf="/tmp/${fontname}.ttf"
      curl -sL "https://github.com/google/fonts/raw/main/ofl/${urlpath}" -o "${ttf}"
      mkdir -p "fonts/${fontname}"
      node -e "
        const fontnik = require('fontnik');
        const fs = require('fs');
        const font = fs.readFileSync('${ttf}');
        (async () => {
          for (let s = 0; s < 65536; s += 256) {
            try {
              const g = await new Promise((res, rej) => fontnik.range({font, start:s, end:s+255}, (e,d) => e?rej(e):res(d)));
              fs.writeFileSync('fonts/${fontname}/' + s + '-' + (s+255) + '.pbf', g);
            } catch(e) {}
          }
          console.log('  Generated ${fontname}');
        })();
      " 2>/dev/null
      rm -f "${ttf}"
    done
  else
    echo "  Warning: npx not available, cursive fonts not generated (Ye Olde style will fall back to Noto Sans)"
  fi
fi
