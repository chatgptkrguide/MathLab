#!/usr/bin/env python3
"""MathLab branding asset generator — v2 (polished design).

Generates app icons, web PWA icons, splash images, and login logo
with a modern, vibrant design language.
"""

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT_PATH = str(ROOT / "assets" / "fonts" / "Roboto-Bold.ttf")
FONT_MED_PATH = str(ROOT / "assets" / "fonts" / "Roboto-Medium.ttf")
FONT_KR_PATH = str(ROOT / "assets" / "fonts" / "NotoSansKR-Variable.ttf")

# Brand palette
BG_TOP = (56, 139, 255)        # bright blue
BG_BOTTOM = (30, 68, 200)      # deep blue
ACCENT = (99, 179, 255)        # light accent
GLOW = (120, 190, 255)         # glow colour
WHITE = (255, 255, 255)

random.seed(42)  # deterministic "random" decoration


def _radial_gradient(size: int) -> Image.Image:
    """Radial gradient: lighter centre, darker edges."""
    img = Image.new("RGBA", (size, size))
    cx, cy = size / 2, size / 2
    max_r = math.hypot(cx, cy)
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - cx, y - cy) / max_r
            d = min(d, 1.0)
            # Centre → lighter, edges → darker
            t = d * d  # ease-in for smoother falloff
            r = int(BG_TOP[0] + (BG_BOTTOM[0] - BG_TOP[0]) * t)
            g = int(BG_TOP[1] + (BG_BOTTOM[1] - BG_TOP[1]) * t)
            b = int(BG_TOP[2] + (BG_BOTTOM[2] - BG_TOP[2]) * t)
            img.putpixel((x, y), (r, g, b, 255))
    return img


def _draw_glow_circle(
    img: Image.Image, cx: int, cy: int, radius: int, colour: tuple, blur: int = 20
) -> Image.Image:
    """Draw a soft glowing circle."""
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        fill=colour,
    )
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    return Image.alpha_composite(img, layer)


def _scatter_symbols(draw: ImageDraw.Draw, size: int, font_path: str) -> None:
    """Scatter small math symbols around the edges for decoration."""
    symbols = ["+", "=", "\u00D7", "\u00F7", "%", "\u03B1", "\u03B2", "\u0394",
               "0", "1", "2", "3", "7", "9"]
    positions = []
    for _ in range(22):
        # Keep symbols in the outer ring (avoid centre where π sits)
        angle = random.uniform(0, 2 * math.pi)
        dist = random.uniform(size * 0.40, size * 0.47)
        x = size / 2 + math.cos(angle) * dist
        y = size / 2 + math.sin(angle) * dist
        positions.append((int(x), int(y)))

    for pos in positions:
        sym = random.choice(symbols)
        fs = random.randint(int(size * 0.03), int(size * 0.06))
        alpha = random.randint(40, 100)
        try:
            f = ImageFont.truetype(font_path, fs)
        except OSError:
            f = ImageFont.load_default()
        draw.text(pos, sym, fill=(255, 255, 255, alpha), font=f, anchor="mm")


def generate_app_icon() -> Image.Image:
    size = 1024
    cx, cy = size // 2, size // 2

    # 1. Radial gradient background
    img = _radial_gradient(size)

    # 2. Scatter decorative math symbols behind the main circle
    sym_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sym_layer)
    _scatter_symbols(sd, size, FONT_PATH)
    img = Image.alpha_composite(img, sym_layer)

    # 3. Outer glow ring (subtle)
    img = _draw_glow_circle(img, cx, cy, int(size * 0.35), (*GLOW, 25), blur=40)

    # 4. Frosted glass circle — white semi-transparent with soft edge
    circle_r = int(size * 0.32)
    glass = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glass)
    # Outer ring highlight
    gd.ellipse(
        [cx - circle_r - 4, cy - circle_r - 4, cx + circle_r + 4, cy + circle_r + 4],
        fill=(255, 255, 255, 30),
    )
    # Main glass circle
    gd.ellipse(
        [cx - circle_r, cy - circle_r, cx + circle_r, cy + circle_r],
        fill=(255, 255, 255, 55),
    )
    # Inner lighter area (top half — light reflection)
    reflection = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    rd = ImageDraw.Draw(reflection)
    ref_r = int(circle_r * 0.92)
    rd.ellipse(
        [cx - ref_r, cy - ref_r - int(size * 0.04), cx + ref_r, cy + ref_r - int(size * 0.04)],
        fill=(255, 255, 255, 25),
    )
    # Clip reflection to top half only
    clip = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    cd = ImageDraw.Draw(clip)
    cd.rectangle([0, 0, size, cy - int(size * 0.02)], fill=(255, 255, 255, 255))
    reflection = Image.composite(reflection, Image.new("RGBA", (size, size), (0, 0, 0, 0)), clip)
    glass = Image.alpha_composite(glass, reflection)

    img = Image.alpha_composite(img, glass)

    # 5. Pi symbol — large, bold, with drop shadow and subtle glow
    draw = ImageDraw.Draw(img)
    try:
        pi_font = ImageFont.truetype(FONT_PATH, int(size * 0.36))
    except OSError:
        pi_font = ImageFont.load_default()

    pi = "\u03C0"
    bbox = draw.textbbox((0, 0), pi, font=pi_font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    tx = cx - tw // 2 - bbox[0]
    ty = cy - th // 2 - bbox[1] - int(size * 0.02)

    # Glow behind pi
    glow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gld = ImageDraw.Draw(glow_layer)
    gld.text((tx, ty), pi, fill=(*GLOW, 90), font=pi_font)
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(18))
    img = Image.alpha_composite(img, glow_layer)

    # Drop shadow
    shadow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sld = ImageDraw.Draw(shadow_layer)
    sld.text((tx + 4, ty + 6), pi, fill=(0, 0, 50, 60), font=pi_font)
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(6))
    img = Image.alpha_composite(img, shadow_layer)

    # Main pi text
    draw = ImageDraw.Draw(img)
    draw.text((tx, ty), pi, fill=WHITE, font=pi_font)

    # 6. Sub-symbols line: ∫ Σ √
    try:
        sym_font = ImageFont.truetype(FONT_PATH, int(size * 0.065))
    except OSError:
        sym_font = ImageFont.load_default()

    sub = "\u222B   \u03A3   \u221A"
    sbbox = draw.textbbox((0, 0), sub, font=sym_font)
    sw = sbbox[2] - sbbox[0]
    sx = cx - sw // 2 - sbbox[0]
    sy = cy + int(size * 0.20)
    # Shadow
    draw.text((sx + 2, sy + 2), sub, fill=(0, 0, 50, 35), font=sym_font)
    draw.text((sx, sy), sub, fill=(255, 255, 255, 210), font=sym_font)

    # 7. Tiny decorative dots (3 dots below symbols)
    dot_y = sy + int(size * 0.09)
    for dx in [-20, 0, 20]:
        dot_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        dd = ImageDraw.Draw(dot_layer)
        dd.ellipse(
            [cx + dx - 4, dot_y - 4, cx + dx + 4, dot_y + 4],
            fill=(255, 255, 255, 120),
        )
        img = Image.alpha_composite(img, dot_layer)

    return img


# ---------------------------------------------------------------------------
# Maskable variant
# ---------------------------------------------------------------------------
def make_maskable(icon: Image.Image, target_size: int) -> Image.Image:
    padding = int(target_size * 0.2)
    inner = target_size - 2 * padding
    resized = icon.resize((inner, inner), Image.LANCZOS)
    out = Image.new("RGBA", (target_size, target_size), BG_BOTTOM + (255,))
    out.paste(resized, (padding, padding), resized)
    return out


# ---------------------------------------------------------------------------
# Login logo
# ---------------------------------------------------------------------------
def generate_login_logo() -> Image.Image:
    w, h = 864, 260
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # "MathLab" title
    try:
        title_font = ImageFont.truetype(FONT_PATH, 88)
    except OSError:
        title_font = ImageFont.load_default()

    title = "MathLab"
    tbbox = draw.textbbox((0, 0), title, font=title_font)
    tw = tbbox[2] - tbbox[0]
    tx = (w - tw) // 2 - tbbox[0]

    # Glow behind title
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.text((tx, 30), title, fill=(*GLOW, 70), font=title_font)
    glow = glow.filter(ImageFilter.GaussianBlur(12))
    img = Image.alpha_composite(img, glow)

    draw = ImageDraw.Draw(img)
    draw.text((tx, 30), title, fill=WHITE, font=title_font)

    # Divider line
    line_y = 140
    line_hw = int(tw * 0.4)
    draw.line(
        [(w // 2 - line_hw, line_y), (w // 2 + line_hw, line_y)],
        fill=(255, 255, 255, 80),
        width=2,
    )

    # Subtitle — use Korean-capable font
    try:
        sub_font = ImageFont.truetype(FONT_KR_PATH, 30)
    except OSError:
        try:
            sub_font = ImageFont.truetype(FONT_MED_PATH, 30)
        except OSError:
            sub_font = ImageFont.load_default()

    subtitle = "매일 5분, 수학이 쉬워진다"
    sbbox = draw.textbbox((0, 0), subtitle, font=sub_font)
    sw = sbbox[2] - sbbox[0]
    sx = (w - sw) // 2 - sbbox[0]
    draw.text((sx, 160), subtitle, fill=(255, 255, 255, 190), font=sub_font)

    return img


# ---------------------------------------------------------------------------
# Utils
# ---------------------------------------------------------------------------
def save(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(str(path), "PNG")
    print(f"  -> {path.relative_to(ROOT)}  ({img.size[0]}x{img.size[1]})")


def main() -> None:
    print("Generating MathLab branding assets (v2)...\n")

    # 1. Master icon
    print("[1/4] Master app icon (1024x1024)")
    icon = generate_app_icon()
    save(icon, ROOT / "assets" / "images" / "app_icon.png")

    # 2. Web icons
    print("\n[2/4] Web icons")
    for name, sz in [("favicon.png", 32)]:
        save(icon.resize((sz, sz), Image.LANCZOS), ROOT / "web" / name)
    for name, sz in [("Icon-192.png", 192), ("Icon-512.png", 512)]:
        save(icon.resize((sz, sz), Image.LANCZOS), ROOT / "web" / "icons" / name)
    for name, sz in [("Icon-maskable-192.png", 192), ("Icon-maskable-512.png", 512)]:
        save(make_maskable(icon, sz), ROOT / "web" / "icons" / name)

    # 3. Splash images
    print("\n[3/4] Web splash images")
    for label, sz in {"1x": 256, "2x": 512, "3x": 768, "4x": 1024}.items():
        splash = icon.resize((sz, sz), Image.LANCZOS)
        save(splash, ROOT / "web" / "splash" / "img" / f"light-{label}.png")
        save(splash, ROOT / "web" / "splash" / "img" / f"dark-{label}.png")

    # 4. Login logo
    print("\n[4/4] Login logo")
    save(generate_login_logo(), ROOT / "assets" / "images" / "login" / "logo.png")

    print("\nDone!")


if __name__ == "__main__":
    main()
