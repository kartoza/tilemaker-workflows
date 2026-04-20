# Tilemaker Workflows — Package Inventory

Annotated list of all packages in the development environment, their role in the architecture, and why they're included.

---

## Core Processing Tools

| Package | Version Source | Purpose |
|---------|---------------|---------|
| **tilemaker** | nixpkgs (3.0.0) | Vector tile generator — converts OSM PBF data to MBTiles using Lua processing scripts and JSON layer configs |
| **mbtileserver** | nixpkgs | Tile server — serves `.mbtiles` files over HTTP with TileJSON metadata, map preview, and CORS support |
| **osmium-tool** | nixpkgs | OSM data toolkit — used to optimise/convert PBF files for faster tilemaker processing (`osmium cat`) |
| **mapnik** | nixpkgs | Map rendering library — provides supporting utilities for spatial data processing |

## Data Acquisition

| Package | Version Source | Purpose |
|---------|---------------|---------|
| **curl** | nixpkgs | HTTP client — downloads OSM PBF extracts, Natural Earth data, and coastline shapefiles |
| **wget** | nixpkgs | HTTP client — alternative downloader for large files with resume support |
| **unzip** | nixpkgs | Archive extraction — unpacks Natural Earth and water polygon ZIP archives |

## Style Editing

| Package | Version Source | Purpose |
|---------|---------------|---------|
| **nodejs** | nixpkgs | JavaScript runtime — required to build and run the Maputnik map style editor locally |

## Development & Quality

| Package | Version Source | Purpose |
|---------|---------------|---------|
| **shellcheck** | nixpkgs | Shell script linter — catches common bash pitfalls, quoting issues, and portability problems |
| **luajitPackages.luacheck** | nixpkgs | Lua linter — validates processing scripts with tilemaker-specific global declarations |
| **nixfmt-rfc-style** | nixpkgs | Nix formatter — enforces consistent formatting in `flake.nix` per RFC style |
| **git** | nixpkgs | Version control — submodule management (maputnik), pre-commit hook execution |
| **jq** | nixpkgs | JSON processor — useful for inspecting and validating layer configurations |

## Terminal Experience

| Package | Version Source | Purpose |
|---------|---------------|---------|
| **byobu** | nixpkgs | Terminal multiplexer — manage long-running tile generation and server processes side-by-side |
| **gotop** | nixpkgs | System monitor — observe CPU/RAM/disk usage during intensive tile generation |
| **tailor** | github:wimpysworld/tailor | Terminal customisation — shell prompt theming and environment indicators |

## Pre-commit Hooks (auto-installed)

| Hook | Purpose |
|------|---------|
| **shellcheck** | Lint `.sh` files on commit |
| **luacheck** | Lint `.lua` files on commit |
| **nixfmt-rfc-style** | Format `.nix` files on commit |
| **trim-trailing-whitespace** | Remove trailing spaces |
| **end-of-file-fixer** | Ensure newline at EOF |
| **check-added-large-files** | Prevent accidental binary commits |

---

## Dependency Graph

```
User Workflow
├── Data Download (curl, wget, unzip)
│   ├── Natural Earth shapefiles
│   ├── OSM water polygons
│   └── OSM PBF extracts
├── Processing (osmium-tool → tilemaker)
│   ├── config.json (layer definitions)
│   └── process.lua (feature classification)
├── Serving (mbtileserver)
│   └── TileJSON API on :8000
└── Styling (nodejs → maputnik)
    └── MapLibre GL style editor on :8888
```

---

## Adding Packages

To add a new package to the development environment:

1. Add it to `devShells.default.buildInputs` in `flake.nix`
2. Run `nix flake lock --update-input nixpkgs` if needed
3. Update this file with the package's role
4. Enter the shell with `nix develop` or `direnv reload`
