#!/usr/bin/env python3
"""Add sprite references and icon layers to all map styles.

Adds appropriate Maki/Temaki icons for POIs, aerodromes, parks,
mountain peaks, and other features to every style that doesn't
already have icon layers.
"""

import json
import glob
import os

STYLES_DIR = "styles"
SPRITE_URL = "/sprites/icons"

# POI class -> icon name mapping (Maki icon names)
POI_ICONS = {
    "restaurant": "restaurant",
    "cafe": "cafe",
    "bar": "bar",
    "pub": "beer",
    "fast_food": "fast-food",
    "hospital": "hospital",
    "clinic": "hospital",
    "pharmacy": "pharmacy",
    "school": "school",
    "university": "college",
    "college": "college",
    "library": "library",
    "museum": "museum",
    "theatre": "theatre",
    "cinema": "cinema",
    "place_of_worship": "place-of-worship",
    "bank": "bank",
    "atm": "bank",
    "post_office": "post",
    "police": "police",
    "fire_station": "fire-station",
    "fuel": "fuel",
    "parking": "parking",
    "bus_stop": "bus",
    "bus_station": "bus",
    "supermarket": "grocery",
    "convenience": "convenience",
    "bakery": "bakery",
    "butcher": "slaughterhouse",
    "clothes": "clothing-store",
    "hotel": "lodging",
    "hostel": "lodging",
    "camp_site": "campsite",
    "swimming_pool": "swimming",
    "sports_centre": "stadium",
    "pitch": "soccer",
    "playground": "playground",
    "garden": "garden",
    "zoo": "zoo",
    "information": "information",
    "viewpoint": "viewpoint",
    "picnic_site": "picnic-site",
    "toilets": "toilet",
    "drinking_water": "drinking-water",
    "recycling": "recycling",
}


def get_style_text_color(style):
    """Extract the primary text color from a style for icon tinting."""
    for layer in style.get("layers", []):
        if layer.get("id") == "place-city":
            return layer.get("paint", {}).get("text-color", "#333333")
    return "#333333"


def get_style_halo(style):
    """Extract text halo settings from the style."""
    for layer in style.get("layers", []):
        if layer.get("id") == "place-city":
            paint = layer.get("paint", {})
            return {
                "color": paint.get("text-halo-color", "rgba(255,255,255,0.9)"),
                "width": paint.get("text-halo-width", 2),
            }
    return {"color": "rgba(255,255,255,0.9)", "width": 2}


def make_icon_layers(style):
    """Generate icon layers appropriate for a style."""
    halo = get_style_halo(style)
    text_color = get_style_text_color(style)

    layers = []

    # Aerodrome with plane icon
    layers.append({
        "id": "aerodrome-icon",
        "type": "symbol",
        "source": "planet",
        "source-layer": "aerodrome_label",
        "minzoom": 10,
        "layout": {
            "icon-image": "airport",
            "icon-size": ["interpolate", ["linear"], ["zoom"], 10, 0.5, 14, 0.8],
            "text-field": ["coalesce", ["get", "name:latin"], ["get", "name"]],
            "text-font": style.get("_label_font", ["Noto Sans Regular"]),
            "text-size": 10,
            "text-offset": [0, 1.5],
            "text-anchor": "top",
            "text-optional": True,
        },
        "paint": {
            "text-color": text_color,
            "text-halo-color": halo["color"],
            "text-halo-width": halo["width"],
            "icon-opacity": 0.85,
        },
    })

    # Mountain peak with mountain icon
    layers.append({
        "id": "mountain-peak-icon",
        "type": "symbol",
        "source": "planet",
        "source-layer": "mountain_peak",
        "minzoom": 11,
        "layout": {
            "icon-image": "mountain",
            "icon-size": ["interpolate", ["linear"], ["zoom"], 11, 0.5, 14, 0.7],
            "text-field": [
                "concat",
                ["coalesce", ["get", "name:latin"], ["get", "name"]],
                "\n",
                ["case", ["has", "ele"], ["concat", ["get", "ele"], "m"], ""],
            ],
            "text-font": style.get("_label_font", ["Noto Sans Regular"]),
            "text-size": 10,
            "text-offset": [0, 1.5],
            "text-anchor": "top",
        },
        "paint": {
            "text-color": text_color,
            "text-halo-color": halo["color"],
            "text-halo-width": halo["width"],
            "icon-opacity": 0.8,
        },
    })

    # POI with contextual icons
    layers.append({
        "id": "poi-icons",
        "type": "symbol",
        "source": "planet",
        "source-layer": "poi",
        "minzoom": 14,
        "filter": ["<=", "rank", 5],
        "layout": {
            "icon-image": [
                "match", ["get", "subclass"],
                "restaurant", "restaurant",
                "cafe", "cafe",
                "bar", "bar",
                "pub", "beer",
                "fast_food", "fast-food",
                "hospital", "hospital",
                "clinic", "hospital",
                "pharmacy", "pharmacy",
                "school", "school",
                "university", "college",
                "library", "library",
                "museum", "museum",
                "theatre", "theatre",
                "cinema", "cinema",
                "place_of_worship", "place-of-worship",
                "bank", "bank",
                "post_office", "post",
                "police", "police",
                "fire_station", "fire-station",
                "fuel", "fuel",
                "parking", "parking",
                "supermarket", "grocery",
                "convenience", "convenience",
                "bakery", "bakery",
                "hotel", "lodging",
                "camp_site", "campsite",
                "swimming_pool", "swimming",
                "playground", "playground",
                "garden", "garden",
                "zoo", "zoo",
                "information", "information",
                "viewpoint", "viewpoint",
                "toilets", "toilet",
                "drinking_water", "drinking-water",
                "marker",  # fallback
            ],
            "icon-size": 0.6,
            "text-field": ["coalesce", ["get", "name:latin"], ["get", "name"]],
            "text-font": style.get("_label_font", ["Noto Sans Regular"]),
            "text-size": 10,
            "text-offset": [0, 1.3],
            "text-anchor": "top",
            "text-optional": True,
        },
        "paint": {
            "text-color": text_color,
            "text-halo-color": halo["color"],
            "text-halo-width": halo["width"],
            "icon-opacity": 0.85,
        },
    })

    return layers


def get_label_font(style):
    """Detect the font used for labels in this style."""
    for layer in style.get("layers", []):
        if layer.get("id") in ("poi", "road-label-primary", "mountain-peak"):
            layout = layer.get("layout", {})
            font = layout.get("text-font")
            if font:
                return font
    return ["Noto Sans Regular"]


def update_style(filepath):
    """Add sprite reference and icon layers to a style file."""
    with open(filepath) as f:
        style = json.load(f)

    name = style.get("name", "")

    # Skip pointillist (already fully icon-based) and places (will be created separately)
    if name in ("Pointillist", "Places"):
        return False

    # Already has sprite reference and icon layers
    existing_ids = {l["id"] for l in style.get("layers", [])}
    if "poi-icons" in existing_ids:
        return False

    # Add sprite reference
    style["sprite"] = SPRITE_URL

    # Detect label font for this style
    style["_label_font"] = get_label_font(style)

    # Remove old non-icon versions of these layers
    remove_ids = {"aerodrome-label", "mountain-peak", "poi"}
    style["layers"] = [l for l in style["layers"] if l["id"] not in remove_ids]

    # Add icon layers at the end (on top)
    icon_layers = make_icon_layers(style)
    style["layers"].extend(icon_layers)

    # Clean up internal key
    del style["_label_font"]

    with open(filepath, "w") as f:
        json.dump(style, f, indent=2)
        f.write("\n")

    return True


def main():
    style_files = sorted(glob.glob(os.path.join(STYLES_DIR, "*.json")))
    updated = 0
    for fp in style_files:
        basename = os.path.basename(fp)
        if update_style(fp):
            print(f"  Updated {basename}")
            updated += 1
        else:
            print(f"  Skipped {basename}")

    print(f"\n  {updated}/{len(style_files)} styles updated with icons")


if __name__ == "__main__":
    main()
