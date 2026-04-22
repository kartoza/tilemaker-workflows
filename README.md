# Tilemaker Workflows

**OpenMapTiles-compliant vector tile generation from OpenStreetMap data at any scale.**

Generate beautiful, standards-compliant vector tiles from country extracts to the entire planet using [Tilemaker](https://tilemaker.org), serve them locally, and style them with Maputnik — all within a reproducible Nix flake environment.

[![Built with Nix](https://img.shields.io/badge/Built_with-Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![OpenMapTiles Schema](https://img.shields.io/badge/Schema-OpenMapTiles_v3-green)](https://openmaptiles.org/schema/)

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Workflows](#workflows)
  - [Coastline Generation](#coastline-generation)
  - [Country Processing](#country-processing)
  - [Planet Processing](#planet-processing)
  - [Tile Serving](#tile-serving)
  - [Style Editing with Maputnik](#style-editing-with-maputnik)
- [Development](#development)
  - [Nix Run Commands](#nix-run-commands)
  - [Pre-commit Hooks](#pre-commit-hooks)
  - [Neovim Integration](#neovim-integration)
- [Architecture](#architecture)
- [Credits](#credits)

---

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (recommended)

```bash
# Enter the development shell
nix develop

# Or with direnv (automatic on cd)
direnv allow
```

---

## Quick Start

```bash
# 1. Enter the dev environment
nix develop

# 2. Generate Malta tiles (fast, good for testing)
nix run .#processMalta

# 3. Serve tiles locally
nix run .#serve

# 4. Browse at http://localhost:8000/services/
```

---

## Workflows

### Coastline Generation

Pre-generate global coastline, water polygon, and landcover tiles:

```bash
nix run .#coastline
```

This downloads required Natural Earth and OSM water polygon data, then generates `coastline.mbtiles` covering the full extent (-180,-85,180,85).

### Country Processing

Process individual country extracts (fast iteration for style development):

```bash
nix run .#processMalta
```

Downloads the latest Malta OSM extract from Geofabrik and processes it with performance optimisations (`--fast`, `--no-compress-ways`, `--no-compress-nodes`).

Output: `malta.mbtiles`

![Malta tiles in QGIS](img/malta.png)

### Planet Processing

Generate tiles for the entire OpenStreetMap planet:

```bash
nix run .#processPlanet
```

> **Note:** Requires ~250GB temporary storage in the `work/` directory during processing. The planet PBF download is ~70GB.

The workflow:
1. Downloads `planet-latest.osm.pbf` from OpenStreetMap
2. Optimises with `osmium cat` for faster tilemaker processing
3. Generates `planet.mbtiles` at zoom levels 0–14

### Tile Serving

Serve any `.mbtiles` files in the output directory:

```bash
nix run .#serve     # Start mbtileserver on port 8000
nix run .#viewer    # Serve web viewer & styles on port 8001
```

Browse the service list at http://localhost:8000/services/

![mbtileserver running](img/run_server.png)

### Viewing Tiles

#### Web Viewer

Open the built-in MapLibre GL viewer with multiple styles:

```
http://localhost:8001/viewer.html
```

The viewer includes a style switcher with 7 themes: Classic, Neon, Muted, African, Psychedelic, Sketch, and Kartoza.

#### QGIS

Add tiles as a **Vector Tile** layer in QGIS:

1. **Layer** → **Add Layer** → **Add Vector Tile Layer**
2. Click **New Generic Connection**
3. Set the fields:
   - **Name:** `Planet Tiles`
   - **URL:** `http://localhost:8000/services/planet/tiles/{z}/{x}/{y}.pbf`
   - **Min Zoom:** `0`
   - **Max Zoom:** `14`
   - **Style URL:** `http://localhost:8001/styles/classic.json`
4. Click **OK**, then **Add**

Available styles (use any as the Style URL):

| Style | URL | Description |
|-------|-----|-------------|
| Classic | `http://localhost:8001/styles/classic.json` | Warm natural tones |
| Neon | `http://localhost:8001/styles/neon.json` | Dark cyberpunk |
| Muted | `http://localhost:8001/styles/muted.json` | Analysis backdrop |
| African | `http://localhost:8001/styles/african.json` | Vibrant earth tones |
| Psychedelic | `http://localhost:8001/styles/psychedelic.json` | Bold saturated colours |
| Sketch | `http://localhost:8001/styles/sketch.json` | Pencil on aged paper |
| Kartoza | `http://localhost:8001/styles/kartoza.json` | Kartoza brand teal & orange |

> **Note:** Both `nix run .#serve` (port 8000) and `nix run .#viewer` (port 8001) must be running for QGIS style URLs to work.

#### Embedding in Web Pages

Use the style JSON files directly with MapLibre GL JS:

```html
<script src="https://unpkg.com/maplibre-gl/dist/maplibre-gl.js"></script>
<link href="https://unpkg.com/maplibre-gl/dist/maplibre-gl.css" rel="stylesheet" />
<div id="map" style="width:100%;height:400px;"></div>
<script>
new maplibregl.Map({
  container: "map",
  style: "http://localhost:8001/styles/classic.json",
  center: [0, 20],
  zoom: 2
});
</script>
```

For production, host the style JSON and update the `tiles` URL in the style file to point to your public tile server.

### Style Editing with Maputnik

With the tile server running, launch [Maputnik](https://maplibre.org/maputnik/) for visual style editing:

```bash
nix run .#maputnik
```

Then:
1. Open http://localhost:8888/
2. Click **Open** → **Empty style**
3. Add a data source pointing to `http://localhost:8000/services/planet`
4. Add layers from your tile source

![Maputnik editor](img/new-maputnik.png)
![Adding data sources](img/maputnik-source.png)
![Adding layers](img/add-layer.png)

---

## Development

### Nix Run Commands

| Command | Description |
|---------|-------------|
| `nix run .#getData` | Download required Natural Earth & OSM geodata |
| `nix run .#processMalta` | Generate Malta vector tiles |
| `nix run .#processPlanet` | Generate planet-scale vector tiles |
| `nix run .#coastline` | Generate coastline/landcover tiles |
| `nix run .#serve` | Start mbtileserver on port 8000 |
| `nix run .#viewer` | Serve web viewer & style JSON files on port 8001 |
| `nix run .#maputnik` | Launch Maputnik style editor |
| `nix run .#lint` | Run shellcheck + luacheck |
| `nix fmt` | Format Nix files (nixfmt-rfc-style) |

### Pre-commit Hooks

Pre-commit hooks are automatically installed when entering the dev shell:

- **shellcheck** — Lint shell scripts
- **luacheck** — Lint Lua processing scripts
- **nixfmt-rfc-style** — Format Nix files
- **trim-trailing-whitespace** — Clean up trailing spaces
- **end-of-file-fixer** — Ensure files end with newline
- **check-added-large-files** — Prevent accidental large file commits

Run all hooks manually:

```bash
pre-commit run --all-files
```

### Neovim Integration

The project includes `.exrc` and `.nvim.lua` for seamless Neovim integration:

**Project menu** (requires [which-key.nvim](https://github.com/folke/which-key.nvim)):

| Shortcut | Action |
|----------|--------|
| `<leader>pd` | Download geodata |
| `<leader>pm` | Process Malta |
| `<leader>pp` | Process planet |
| `<leader>pc` | Process coastline |
| `<leader>ps` | Start tile server |
| `<leader>pe` | Launch Maputnik editor |
| `<leader>pl` | Run linters |
| `<leader>pf` | Format nix files |
| `<leader>pt` | Run pre-commit checks |
| `<leader>pr` | Open README |
| `<leader>pS` | Open Specification |

**Lua LSP** is configured to recognise Tilemaker API globals (no false warnings on `Find`, `Layer`, `Attribute`, etc.).

---

## Architecture

```
tilemaker-workflows/
├── flake.nix                 # Nix flake (dev shell, apps, checks)
├── config.json               # Full OpenMapTiles layer configuration (z0-14)
├── config-coastline.json     # Coastline-only layer configuration
├── process.lua               # Main Lua processing script (OpenMapTiles v3)
├── process-coastline.lua     # Coastline/landcover remap script
├── get_data.sh               # Download Natural Earth & OSM water data
├── process_malta.sh          # Malta country tile workflow
├── process_planet.sh         # Planet-scale tile workflow
├── run_server.sh             # mbtileserver launcher
├── run_maputnik_editor.sh    # Maputnik editor launcher
├── viewer.html               # MapLibre GL viewer with style switcher
├── styles/
│   ├── classic.json          # Warm natural tones style
│   ├── neon.json             # Dark cyberpunk style
│   ├── muted.json            # Muted analysis backdrop style
│   ├── african.json          # Vibrant earth tones style
│   ├── psychedelic.json      # Bold saturated colours style
│   └── sketch.json           # Pencil on aged paper style
├── landcover/                # Natural Earth shapefiles
├── img/                      # Documentation screenshots
└── maputnik/                 # MapLibre Maputnik (git submodule)
```

**Data flow:**

```
OSM PBF → [osmium optimise] → tilemaker (Lua + JSON config) → .mbtiles → mbtileserver → styles/*.json → MapLibre/QGIS/Maputnik
```

---

## Credits

**Tim Sutton** (tim@kartoza.com) · **Jeremy Prior** (jeremy@kartoza.com)

Made with 💗 by [Kartoza](https://kartoza.com) | [Donate!](https://github.com/sponsors/kartoza) | [GitHub](https://github.com/kartoza/tilemaker-workflows)
