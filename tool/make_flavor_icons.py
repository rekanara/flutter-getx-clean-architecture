#!/usr/bin/env python3
"""Generate flavor app icons by overlaying a colored corner badge.

Usage: python3 make_flavor_icons.py
Creates assets/icons/app_icon_dev.png and app_icon_staging.png.
The prod icon is the original app_icon.png (no badge).
"""
from PIL import Image, ImageDraw

SRC = "assets/icons/app_icon.png"

FLAVORS = {
    "dev": (155, 39, 176),      # Material Purple 500 - matches Environment.dev badge
    "staging": (255, 152, 0),   # Material Orange 500 - matches Environment.staging badge
}


def make_flavor_icon(color: tuple) -> Image.Image:
    base = Image.open(SRC).convert("RGBA")
    size = base.size[0]
    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    # Badge occupies the top-right diagonal band (like Android debug banner).
    band = size // 3
    # Solid diagonal band in the top-right corner.
    draw.polygon(
        [(size, 0), (size, band), (band, 0)],
        fill=color + (255,),
    )
    # Thin dark edge along the band for contrast on any background.
    draw.line([(band, 0), (size, band)], fill=(0, 0, 0, 120), width=max(2, size // 100))

    return Image.alpha_composite(base, overlay)


for name, color in FLAVORS.items():
    out = make_flavor_icon(color)
    path = f"assets/icons/app_icon_{name}.png"
    out.save(path)
    print(f"wrote {path} ({out.size[0]}x{out.size[1]})")

print("done")
