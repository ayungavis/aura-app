#!/usr/bin/env python3
"""
Frames raw iPhone screenshots into App Store marketing images.

    python3 -m venv .venv && .venv/bin/pip install pillow
    .venv/bin/python AppStore/screenshots/compose.py

Reads   AppStore/screenshots/raw/<name>.png   (any iPhone resolution)
Writes  AppStore/screenshots/output/<size>/<n>-<name>.png
        6.9/ (1320 x 2868) and 6.5/ (1284 x 2778)

Captions live in SHOTS below; a shot whose raw file is missing is skipped.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent
FONTS = ROOT.parents[1] / "AuraApp" / "Resources" / "Fonts"
RAW = ROOT / "raw"
OUT = ROOT / "output"

# App Store Connect display sizes. Layout values below are for 6.9" and scale
# with the canvas width.
CANVASES = {
    "6.9": (1320, 2868),
    "6.5": (1284, 2778),
}

# Matches the app's sky gradient.
TOP = (160, 136, 245)
BOTTOM = (58, 29, 176)
INK = (255, 255, 255)

SHOTS = [
    ("home", "Plans that fit\nthe forecast", "Activities and food picked for today's weather"),
    ("places", "Find it\nnearby", "Places that match the plan, around you"),
    ("detail", "Know before\nyou go", "Hours and directions in one tap"),
]


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / name), size)


def gradient(size: tuple[int, int]) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / (h - 1)
        draw.line([(0, y), (w, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(TOP, BOTTOM)))
    return img


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([(0, 0), img.size], radius=radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def compose(raw_path: Path, title: str, subtitle: str, size: tuple[int, int]) -> Image.Image:
    canvas = gradient(size).convert("RGBA")
    draw = ImageDraw.Draw(canvas)
    cw, ch = size
    scale = cw / 1320

    def px(value: float) -> int:
        return round(value * scale)

    # Captions
    title_font = font("InstrumentSerif-Regular.ttf", px(150))
    sub_font = font("InstrumentSans-Regular.ttf", px(52))
    y = px(190)
    draw.multiline_text((cw / 2, y), title, font=title_font, fill=INK, anchor="ma", align="center", spacing=px(6))
    y += draw.multiline_textbbox((0, 0), title, font=title_font, spacing=px(6))[3] + px(40)
    draw.text((cw / 2, y), subtitle, font=sub_font, fill=INK + (205,), anchor="ma")

    # Device screenshot, bleeding off the bottom edge
    shot = Image.open(raw_path).convert("RGB")
    target_w = int(cw * 0.80)
    shot = shot.resize((target_w, round(shot.height * target_w / shot.width)), Image.LANCZOS)
    shot = rounded(shot, radius=int(target_w * 0.115))

    x = (cw - target_w) // 2
    top = px(860)
    shadow = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [(x, top + px(30)), (x + target_w, top + shot.height + px(30))],
        radius=int(target_w * 0.115),
        fill=(20, 0, 60, 120),
    )
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(px(50))))
    canvas.alpha_composite(shot, (x, top))

    return canvas.convert("RGB")


def main() -> None:
    made = 0
    for index, (name, title, subtitle) in enumerate(SHOTS, start=1):
        raw = RAW / f"{name}.png"
        if not raw.exists():
            print(f"skip  {name}: add {raw.relative_to(ROOT.parents[1])}")
            continue
        for label, size in CANVASES.items():
            out_dir = OUT / label
            out_dir.mkdir(parents=True, exist_ok=True)
            out = out_dir / f"{index:02d}-{name}.png"
            compose(raw, title, subtitle, size).save(out, optimize=True)
            print(f"wrote {out.relative_to(ROOT.parents[1])}")
        made += 1
    print(f"{made}/{len(SHOTS)} screenshots, {len(CANVASES)} sizes each")


if __name__ == "__main__":
    main()
