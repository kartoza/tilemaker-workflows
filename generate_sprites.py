#!/usr/bin/env python3
"""Generate sprite sheets from Maki icons + custom cartographic icons.

Downloads Maki (Mapbox open source map icons) and generates 1x/2x sprite sheets
compatible with MapLibre GL styles.
"""

import io
import json
import math
import os
import shutil
import tempfile

import cairosvg
import requests
from PIL import Image, ImageDraw

OUTPUT_DIR = "sprites"
ICON_SIZE = 24  # base size for custom icons

# Open source icon libraries to download
ICON_LIBRARIES = {
    "maki": {
        "api_url": "https://api.github.com/repos/mapbox/maki/contents/icons",
        "repo_url": "https://github.com/mapbox/maki",
        "license": "CC0-1.0",
        "description": "Mapbox cartographic icons for map POIs",
    },
    "temaki": {
        "api_url": "https://api.github.com/repos/rapideditor/temaki/contents/icons",
        "repo_url": "https://github.com/rapideditor/temaki",
        "license": "CC0-1.0",
        "description": "Extended cartographic icons (companion to Maki)",
    },
}


# ---------------------------------------------------------------------------
# Icon library downloading
# ---------------------------------------------------------------------------

def download_icon_library(name, api_url, dest_dir):
    """Download all SVGs from a GitHub icon library."""
    print(f"  Fetching {name} icon list...")
    resp = requests.get(api_url, timeout=30)
    resp.raise_for_status()
    files = resp.json()

    svgs = [f for f in files if f["name"].endswith(".svg")]
    print(f"  Downloading {len(svgs)} {name} icons...")

    downloaded = []
    for f in svgs:
        svg_name = f["name"]
        url = f["download_url"]
        try:
            svg_data = requests.get(url, timeout=15).content
            # Prefix temaki icons to avoid name collisions with maki
            out_name = f"temaki-{svg_name}" if name == "temaki" else svg_name
            with open(os.path.join(dest_dir, out_name), "wb") as out:
                out.write(svg_data)
            downloaded.append(out_name.replace(".svg", ""))
        except Exception as e:
            print(f"    Warning: failed to download {svg_name}: {e}")

    return downloaded


def render_svg_to_png(svg_path, size):
    """Render an SVG file to a PIL Image at the given pixel size."""
    png_data = cairosvg.svg2png(
        url=svg_path,
        output_width=size,
        output_height=size,
    )
    return Image.open(io.BytesIO(png_data)).convert("RGBA")


# ---------------------------------------------------------------------------
# Custom drawn icons (for features Maki doesn't cover well)
# ---------------------------------------------------------------------------

CUSTOM_ICONS = {}


def custom_icon(name, color):
    """Decorator to register a custom icon draw function."""
    def decorator(fn):
        CUSTOM_ICONS[name] = (fn, color)
        return fn
    return decorator


@custom_icon("tree-green", "#2E7D32")
def draw_tree(d, c):
    d.polygon([(12, 2), (4, 18), (20, 18)], fill=c)
    d.rectangle([10, 18, 14, 22], fill="#5D4037")


@custom_icon("deciduous", "#4CAF50")
def draw_deciduous(d, c):
    d.ellipse([4, 2, 20, 16], fill=c)
    d.rectangle([10, 14, 14, 22], fill="#5D4037")


@custom_icon("grass-blades", "#7CB342")
def draw_grass(d, c):
    for x in [6, 12, 18]:
        d.line([(x, 20), (x - 3, 8)], fill=c, width=2)
        d.line([(x, 20), (x + 3, 8)], fill=c, width=2)


@custom_icon("crop", "#F9A825")
def draw_crop(d, c):
    d.line([(12, 22), (12, 6)], fill=c, width=2)
    d.ellipse([8, 2, 16, 10], fill=c)
    d.line([(6, 18), (12, 12)], fill=c, width=2)
    d.line([(18, 18), (12, 12)], fill=c, width=2)


@custom_icon("wave", "#2196F3")
def draw_wave(d, c):
    for y in [8, 14, 20]:
        pts = []
        for x in range(2, 23):
            pts.append((x, y + 3 * math.sin(x * 0.8)))
        d.line(pts, fill=c, width=2)


@custom_icon("sand-dots", "#D4A017")
def draw_sand(d, c):
    for pos in [(6, 6), (14, 8), (10, 14), (18, 12), (8, 20), (16, 18), (4, 12), (20, 6)]:
        d.ellipse([pos[0] - 2, pos[1] - 2, pos[0] + 2, pos[1] + 2], fill=c)


@custom_icon("wetland-reeds", "#00897B")
def draw_wetland(d, c):
    for x in [7, 12, 17]:
        d.line([(x, 22), (x, 8)], fill=c, width=2)
        d.ellipse([x - 2, 5, x + 2, 10], fill=c)
    d.line([(3, 20), (21, 20)], fill="#5b8fb9", width=1)


@custom_icon("snowflake", "#90CAF9")
def draw_snowflake(d, c):
    cx, cy = 12, 12
    for angle in range(0, 360, 60):
        rad = math.radians(angle)
        x2 = cx + 9 * math.cos(rad)
        y2 = cy + 9 * math.sin(rad)
        d.line([(cx, cy), (x2, y2)], fill=c, width=2)


@custom_icon("star-city", "#FF6F00")
def draw_star(d, c):
    points = []
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        r = 10 if i % 2 == 0 else 4
        points.append((12 + r * math.cos(angle), 12 + r * math.sin(angle)))
    d.polygon(points, fill=c)


@custom_icon("circle-town", "#E65100")
def draw_circle(d, c):
    d.ellipse([4, 4, 20, 20], fill=c)


@custom_icon("dot-village", "#BF360C")
def draw_dot(d, c):
    d.ellipse([7, 7, 17, 17], fill=c)


@custom_icon("dot-hamlet", "#8D6E63")
def draw_dot_small(d, c):
    d.ellipse([7, 7, 17, 17], fill=c)


@custom_icon("diamond-poi", "#7B1FA2")
def draw_diamond(d, c):
    d.polygon([(12, 2), (22, 12), (12, 22), (2, 12)], fill=c)


@custom_icon("road-marker", "#424242")
def draw_road_marker(d, c):
    d.ellipse([3, 3, 21, 21], outline=c, width=3)
    d.ellipse([8, 8, 16, 16], fill=c)


@custom_icon("rail-cross", "#616161")
def draw_rail(d, c):
    d.line([(4, 12), (20, 12)], fill=c, width=3)
    d.line([(12, 4), (12, 20)], fill=c, width=3)
    d.ellipse([8, 8, 16, 16], fill=c)


@custom_icon("boundary-post", "#4A148C")
def draw_boundary(d, c):
    d.rectangle([10, 2, 14, 22], fill=c)
    d.polygon([(6, 2), (18, 2), (18, 8), (6, 8)], fill=c)


@custom_icon("flag-country", "#AD1457")
def draw_flag(d, c):
    d.rectangle([5, 2, 19, 14], fill=c)
    d.line([(5, 2), (5, 22)], fill="#333333", width=2)


@custom_icon("label-dot", "#333333")
def draw_label_dot(d, c):
    """Small subtle dot for label-only markers."""
    d.ellipse([9, 9, 15, 15], fill=c)


def render_custom_icon(name, size):
    """Render a custom drawn icon at the given size."""
    fn, color = CUSTOM_ICONS[name]
    base = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(base)
    fn(d, color)
    if size != ICON_SIZE:
        base = base.resize((size, size), Image.LANCZOS)
    return base


# ---------------------------------------------------------------------------
# Sprite sheet generation
# ---------------------------------------------------------------------------

def generate_sprites(maki_dir, scale=1):
    """Generate sprite sheet combining Maki + custom icons."""
    size = ICON_SIZE * scale
    icons_per_row = 20

    # Collect all icon names
    maki_names = sorted([
        f.replace(".svg", "")
        for f in os.listdir(maki_dir)
        if f.endswith(".svg")
    ])
    custom_names = sorted(CUSTOM_ICONS.keys())
    all_names = maki_names + custom_names

    rows = math.ceil(len(all_names) / icons_per_row)
    sheet = Image.new("RGBA", (icons_per_row * size, rows * size), (0, 0, 0, 0))
    sprite_json = {}

    for i, name in enumerate(all_names):
        row, col = divmod(i, icons_per_row)
        x, y = col * size, row * size

        if name in CUSTOM_ICONS:
            icon = render_custom_icon(name, size)
        else:
            svg_path = os.path.join(maki_dir, f"{name}.svg")
            try:
                icon = render_svg_to_png(svg_path, size)
            except Exception as e:
                print(f"  Warning: failed to render {name}: {e}")
                continue

        sheet.paste(icon, (x, y), icon)
        sprite_json[name] = {
            "width": size,
            "height": size,
            "x": x,
            "y": y,
            "pixelRatio": scale,
        }

    return sheet, sprite_json


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Download icon libraries to shared SVG dir
    svg_dir = os.path.join(OUTPUT_DIR, "svg_cache")
    os.makedirs(svg_dir, exist_ok=True)

    existing = [f for f in os.listdir(svg_dir) if f.endswith(".svg")]
    if len(existing) > 100:
        print(f"  Using cached icons in {svg_dir} ({len(existing)} SVGs)")
    else:
        for lib_name, lib_info in ICON_LIBRARIES.items():
            download_icon_library(lib_name, lib_info["api_url"], svg_dir)

    maki_dir = svg_dir

    # Generate 1x
    print("  Generating 1x sprite sheet...")
    sheet1, json1 = generate_sprites(maki_dir, 1)
    sheet1.save(f"{OUTPUT_DIR}/icons.png")
    with open(f"{OUTPUT_DIR}/icons.json", "w") as f:
        json.dump(json1, f, indent=2)

    # Generate 2x
    print("  Generating 2x sprite sheet...")
    sheet2, json2 = generate_sprites(maki_dir, 2)
    sheet2.save(f"{OUTPUT_DIR}/icons@2x.png")
    with open(f"{OUTPUT_DIR}/icons@2x.json", "w") as f:
        json.dump(json2, f, indent=2)

    icon_count = len(json1)
    maki_count = len([f for f in os.listdir(maki_dir) if f.endswith(".svg") and not f.startswith("temaki-")])
    temaki_count = len([f for f in os.listdir(maki_dir) if f.startswith("temaki-")])
    custom_count = len(CUSTOM_ICONS)

    # Write provenance metadata
    from datetime import date
    provenance = {
        "generated": date.today().isoformat(),
        "total_icons": icon_count,
        "sources": {},
    }
    for lib_name, lib_info in ICON_LIBRARIES.items():
        provenance["sources"][lib_name] = {
            "repository": lib_info["repo_url"],
            "license": lib_info["license"],
            "description": lib_info["description"],
        }
    provenance["sources"]["custom"] = {
        "description": "Hand-drawn cartographic icons for landcover, places, and infrastructure",
        "license": "CC0-1.0",
        "count": custom_count,
    }
    with open(f"{OUTPUT_DIR}/provenance.json", "w") as f:
        json.dump(provenance, f, indent=2)
        f.write("\n")

    print(f"\n  Generated {icon_count} icons ({maki_count} Maki + {temaki_count} Temaki + {custom_count} custom)")
    print(f"  {OUTPUT_DIR}/icons.png ({sheet1.size[0]}x{sheet1.size[1]})")
    print(f"  {OUTPUT_DIR}/icons@2x.png ({sheet2.size[0]}x{sheet2.size[1]})")
    print(f"  {OUTPUT_DIR}/provenance.json")


if __name__ == "__main__":
    main()
