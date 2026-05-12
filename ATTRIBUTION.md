# Attribution & Data Provenance

This project uses the following open data sources, icon libraries, and software.
All assets are used in compliance with their respective licenses.

## Map Data

| Source | License | URL | Usage |
|--------|---------|-----|-------|
| OpenStreetMap | ODbL 1.0 | https://www.openstreetmap.org/copyright | Vector tile data (roads, buildings, POIs, boundaries, landuse, etc.) |
| Natural Earth | Public Domain | https://www.naturalearthdata.com/ | Urban areas, ice shelves, glaciated areas shapefiles |
| OpenStreetMapData | ODbL 1.0 | https://osmdata.openstreetmap.de/ | Water polygons (split, WGS84) |

**OpenStreetMap data is copyright OpenStreetMap contributors and available under the Open Database License (ODbL).**
See https://www.openstreetmap.org/copyright for details.

## Icon Libraries

| Library | Version | License | URL | Icon Count | Usage |
|---------|---------|---------|-----|------------|-------|
| Maki | latest | CC0 1.0 (Public Domain) | https://github.com/mapbox/maki | ~215 | POI icons, aerodrome, park, mountain markers |
| Temaki | latest | CC0 1.0 (Public Domain) | https://github.com/rapideditor/temaki | ~557 | Extended cartographic icons (transit, sports, religious, etc.) |

Icons are downloaded at build time and combined into sprite sheets for use with MapLibre GL styles.

## Fonts

| Font | License | Source | Usage |
|------|---------|--------|-------|
| Noto Sans (Regular, Bold, Italic) | OFL 1.1 | MapLibre Demotiles / Google Fonts | Primary label font for most styles |
| Amatic SC (Regular, Bold) | OFL 1.1 | Google Fonts | Country/state labels in Sketch 2 style |
| Audiowide Regular | OFL 1.1 | Google Fonts | Road labels in Sci-Fi style |
| Bangers Regular | OFL 1.1 | Google Fonts | Decorative labels |
| Caveat (Regular, Bold) | OFL 1.1 | Google Fonts | Village labels in Sketch 2 style |
| Courgette Regular | OFL 1.1 | Google Fonts | Decorative labels |
| Dancing Script Regular | OFL 1.1 | Google Fonts | Water names in Sketch 2 style |
| Kalam (Regular, Bold) | OFL 1.1 | Google Fonts | City/road labels in Sketch 2 style |
| Lobster Regular | OFL 1.1 | Google Fonts | Decorative labels |
| Orbitron (Regular, Bold) | OFL 1.1 | Google Fonts | Place names in Sci-Fi style |
| Patrick Hand Regular | OFL 1.1 | Google Fonts | Decorative handwriting labels |
| Permanent Marker Regular | OFL 1.1 | Google Fonts | Decorative labels |
| Rajdhani (Regular, Bold) | OFL 1.1 | Google Fonts | Labels in Sci-Fi style |
| Shadows Into Light Regular | OFL 1.1 | Google Fonts | POI labels in Sketch 2 style |
| Special Elite Regular | OFL 1.1 | Google Fonts | Decorative typewriter labels |
| Ubuntu Mono Regular | UFL 1.0 | Google Fonts | Monospace labels |

Font glyphs are generated using [fontnik](https://github.com/mapbox/fontnik) from TTF files
downloaded from [Google Fonts](https://github.com/google/fonts) (Apache 2.0 / OFL 1.1).
Base Noto Sans glyphs are sourced from the [MapLibre Demotiles](https://demotiles.maplibre.org/) server.

## Software

| Software | License | URL | Usage |
|----------|---------|-----|-------|
| Tilemaker | Boost 1.0 | https://tilemaker.org | Vector tile generation from OSM PBF |
| mbtileserver | MIT | https://github.com/consbio/mbtileserver | MBTiles tile serving (TileJSON + PBF) |
| MapLibre GL JS | BSD-3-Clause | https://maplibre.org | Web map rendering in viewer |
| Nginx | BSD-2-Clause | https://nginx.org | Static file serving & reverse proxy |
| Nix | LGPL 2.1 | https://nixos.org | Reproducible builds & development environment |
| OpenMapTiles schema | BSD-3-Clause | https://openmaptiles.org | Vector tile schema definition |

## Tile Schema

This project generates tiles conforming to the [OpenMapTiles v3 schema](https://openmaptiles.org/schema/).
The schema is copyright Klokan Technologies GmbH and contributors, licensed under BSD-3-Clause.

---

*Last updated: 2026-05-12*
