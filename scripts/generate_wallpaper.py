#!/usr/bin/env python3
"""
Generate bespoke high-resolution wallpaper for NivOS:
NivOS Cyber Aurora (3840 x 2160)
Deep obsidian canvas with luminous cyan and indigo ambient gradients,
subtle geometric grid and radial tech elements, and central NivOS insignia.
"""

import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_wallpaper(output_path="/tmp/nivos-cyber-aurora.png", width=3840, height=2160):
    # 1. Base gradient: Midnight obsidian (#050811) to deep navy-slate (#0d172a)
    img = Image.new("RGBA", (width, height), (5, 8, 17, 255))
    draw = ImageDraw.Draw(img)

    # Ambient radial glows
    glow_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)

    cx, cy = width // 2, height // 2 - 60

    # Draw soft cyan / electric glow in center
    radii = [800, 600, 450, 300, 180]
    for r in radii:
        alpha = int(25 * (1.0 - (r / 900)))
        glow_draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(56, 189, 248, alpha) # #38bdf8 cyan
        )

    # Soft violet / indigo glow offset slightly bottom-right
    for r in [650, 480, 320, 150]:
        alpha = int(18 * (1.0 - (r / 750)))
        glow_draw.ellipse(
            [cx + 80 - r, cy + 60 - r, cx + 80 + r, cy + 60 + r],
            fill=(99, 102, 241, alpha) # #6366f1 indigo
        )

    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=60))
    img = Image.alpha_composite(img, glow_layer)

    # 2. Geometric tech lattice / grid (subtle)
    grid_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    grid_draw = ImageDraw.Draw(grid_layer)

    grid_spacing = 80
    for x in range(0, width, grid_spacing):
        dist_x = abs(x - cx) / (width / 2)
        alpha = max(0, int(18 * (1.0 - dist_x * 0.8)))
        if alpha > 0:
            grid_draw.line([(x, 0), (x, height)], fill=(56, 189, 248, alpha), width=1)

    for y in range(0, height, grid_spacing):
        dist_y = abs(y - cy) / (height / 2)
        alpha = max(0, int(18 * (1.0 - dist_y * 0.8)))
        if alpha > 0:
            grid_draw.line([(0, y), (width, y)], fill=(56, 189, 248, alpha), width=1)

    # Fine cross markers at grid intersections near center
    for x in range(cx - 800, cx + 801, grid_spacing * 2):
        for y in range(cy - 500, cy + 501, grid_spacing * 2):
            dist = math.hypot(x - cx, y - cy)
            if 200 < dist < 900:
                grid_draw.line([(x - 4, y), (x + 4, y)], fill=(56, 189, 248, 50), width=1)
                grid_draw.line([(x, y - 4), (x, y + 4)], fill=(56, 189, 248, 50), width=1)

    img = Image.alpha_composite(img, grid_layer)

    # 3. Concentric tech rings & orbit tracks around insignia
    orbit_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    orbit_draw = ImageDraw.Draw(orbit_layer)

    rings = [
        (320, (56, 189, 248, 40), 1),
        (380, (56, 189, 248, 25), 1),
        (460, (99, 102, 241, 30), 1),
        (540, (56, 189, 248, 20), 1),
    ]
    for r, col, w in rings:
        orbit_draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=col, width=w)

    # Segmented orbit ticks
    for angle_deg in range(0, 360, 15):
        rad = math.radians(angle_deg)
        r1, r2 = 375, 385
        x1, y1 = cx + r1 * math.cos(rad), cy + r1 * math.sin(rad)
        x2, y2 = cx + r2 * math.cos(rad), cy + r2 * math.sin(rad)
        orbit_draw.line([(x1, y1), (x2, y2)], fill=(56, 189, 248, 60), width=1)

    img = Image.alpha_composite(img, orbit_layer)

    # 4. Central NivOS Insignia
    insignia_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    ins_draw = ImageDraw.Draw(insignia_layer)

    # Outer Hexagon
    hex_radius = 160
    hex_pts = []
    for i in range(6):
        angle = math.radians(60 * i - 30)
        px = cx + hex_radius * math.cos(angle)
        py = cy + hex_radius * math.sin(angle)
        hex_pts.append((px, py))

    # Inner Hexagon fill
    inner_hex_radius = 152
    inner_hex_pts = []
    for i in range(6):
        angle = math.radians(60 * i - 30)
        px = cx + inner_hex_radius * math.cos(angle)
        py = cy + inner_hex_radius * math.sin(angle)
        inner_hex_pts.append((px, py))

    ins_draw.polygon(hex_pts, fill=(15, 23, 42, 220), outline=(56, 189, 248, 240), width=4)

    # Stylized NivOS "N" Symbol inside Hexagon
    # Left pillar, diagonal chevron, right pillar
    nw = 22 # thickness
    nh = 75
    # Left vertical
    ins_draw.rectangle([cx - 50, cy - nh, cx - 50 + nw, cy + nh], fill=(241, 245, 249, 240))
    # Right vertical
    ins_draw.rectangle([cx + 50 - nw, cy - nh, cx + 50, cy + nh], fill=(241, 245, 249, 240))
    # Diagonal strike
    diag_pts = [
        (cx - 50, cy - nh),
        (cx - 50 + nw + 6, cy - nh),
        (cx + 50, cy + nh),
        (cx + 50 - nw - 6, cy + nh),
    ]
    ins_draw.polygon(diag_pts, fill=(56, 189, 248, 255))

    # 5. NivOS Typography
    font_bold_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
    font_mono_path = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"

    try:
        font_logo = ImageFont.truetype(font_bold_path, size=52)
        font_sub = ImageFont.truetype(font_mono_path, size=20)
        font_tag = ImageFont.truetype(font_mono_path, size=15)
    except Exception:
        font_logo = ImageFont.load_default()
        font_sub = ImageFont.load_default()
        font_tag = ImageFont.load_default()

    # Brand Title: "N I V O S"
    title_text = "N  I  V  O  S"
    tb = ins_draw.textbbox((0, 0), title_text, font=font_logo)
    tw = tb[2] - tb[0]
    ins_draw.text((cx - tw // 2, cy + hex_radius + 45), title_text, font=font_logo, fill=(248, 250, 252, 250))

    # Subtitle: "HIGH PERFORMANCE AI COMPUTE PLATFORM"
    sub_text = "HIGH PERFORMANCE AI COMPUTE PLATFORM"
    sb = ins_draw.textbbox((0, 0), sub_text, font=font_sub)
    sw = sb[2] - sb[0]
    ins_draw.text((cx - sw // 2, cy + hex_radius + 115), sub_text, font=font_sub, fill=(56, 189, 248, 220))

    # Small architectural spec tag: "COSMIC • LINUX 7.3 • DEBIAN SID"
    spec_text = "COSMIC EPOCH • LINUX 7.3 • DEBIAN SID"
    spb = ins_draw.textbbox((0, 0), spec_text, font=font_tag)
    spw = spb[2] - spb[0]
    ins_draw.text((cx - spw // 2, cy + hex_radius + 150), spec_text, font=font_tag, fill=(148, 163, 184, 160))

    img = Image.alpha_composite(img, insignia_layer)

    # Convert to RGB and save PNG
    rgb_img = img.convert("RGB")
    rgb_img.save(output_path, "PNG", optimize=True)
    print(f"Generated NivOS Cyber Aurora wallpaper: {output_path} ({width}x{height})")

if __name__ == "__main__":
    import sys
    out = sys.argv[1] if len(sys.argv) > 1 else "/var/tmp/nivos-cyber-aurora.png"
    create_wallpaper(output_path=out)
