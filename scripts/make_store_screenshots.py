#!/usr/bin/env python3
"""Compose captioned App Store screenshots from the raw device captures.

The raw shots come from the XCUITest marketing suite:

    xcodebuild test -only-testing:TesserissUITests/ScreenshotTests \\
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \\
      -resultBundlePath out.xcresult
    xcrun xcresulttool export attachments --path out.xcresult --output-path raw/

This wraps each one in a captioned frame in the app's own palette and typeface
(SF Rounded, same as the UI). Caption text is *not* indexed by App Store search —
it earns its place on conversion, not keywords.

    python3 scripts/make_store_screenshots.py raw/ out/

Output is 1320x2868, the 6.9" size App Store Connect expects.
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1320, 2868
FONT_PATH = "/System/Library/Fonts/SFNSRounded.ttf"

# Palette lifted from Assets.xcassets so the frames match the app exactly.
DAY = {"bg": (244, 242, 238), "ink": (45, 45, 45), "sub": (120, 118, 112)}
NIGHT = {"bg": (11, 11, 13), "ink": (237, 237, 232), "sub": (140, 140, 146)}

CAPTIONS = {
    "en": {
        "01-menu":            ("Tear the rows.", "Four at a time.", DAY),
        "02-game":            ("Classic arcade feel,", "modern controls.", DAY),
        "03-settings":        ("Day or night.", "Classic or Hokusai.", DAY),
        "04-game-night":      ("Calm piano. No ads.", "Works fully offline.", NIGHT),
        "05-four-line-flash": ("Four rows at once.", "A great wave.", DAY),
    },
    "tr": {
        "01-menu":            ("Sıraları yırt.", "Dörder dörder.", DAY),
        "02-game":            ("Klasik arcade hissi,", "modern kontroller.", DAY),
        "03-settings":        ("Gündüz ya da gece.", "Klasik ya da Hokusai.", DAY),
        "04-game-night":      ("Sakin piyano. Reklamsız.", "Tamamen çevrimdışı.", NIGHT),
        "05-four-line-flash": ("Tek seferde dört sıra.", "Muhteşem bir dalga.", DAY),
    },
}

CAPTION_TOP = 156      # where the first line of text starts
DEVICE_TOP = 470       # where the device screenshot starts
BOTTOM_MARGIN = 80
SIDE_MARGIN = 130
CORNER = 54


def load_font(size, weight="Semibold"):
    font = ImageFont.truetype(FONT_PATH, size)
    try:
        font.set_variation_by_name(weight)
    except Exception:
        pass  # static build of the font; the default weight is fine
    return font


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (size[0] - 1, size[1] - 1)],
                                           radius=radius, fill=255)
    return mask


def compose(src_path, line1, line2, palette, dest):
    shot = Image.open(src_path).convert("RGB")

    canvas = Image.new("RGB", (W, H), palette["bg"])
    draw = ImageDraw.Draw(canvas)

    title = load_font(88, "Bold")
    for i, line in enumerate((line1, line2)):
        if not line:
            continue
        colour = palette["ink"] if i == 0 else palette["sub"]
        bbox = draw.textbbox((0, 0), line, font=title)
        x = (W - (bbox[2] - bbox[0])) // 2 - bbox[0]
        draw.text((x, CAPTION_TOP + i * 108), line, font=title, fill=colour)

    # Scale the device shot into whatever height is left, keeping its aspect.
    avail_h = H - DEVICE_TOP - BOTTOM_MARGIN
    scale = min(avail_h / shot.height, (W - 2 * SIDE_MARGIN) / shot.width)
    dw, dh = int(shot.width * scale), int(shot.height * scale)
    shot = shot.resize((dw, dh), Image.LANCZOS)
    dx, dy = (W - dw) // 2, DEVICE_TOP

    # Soft drop shadow so the device reads as a separate plane from the frame.
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [(dx, dy + 16), (dx + dw, dy + dh + 16)], radius=CORNER, fill=(0, 0, 0, 70))
    shadow = shadow.filter(ImageFilter.GaussianBlur(26))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow).convert("RGB")

    canvas.paste(shot, (dx, dy), rounded_mask((dw, dh), CORNER))
    canvas.save(dest, "PNG")
    print(f"  {dest.name}  ({canvas.width}x{canvas.height})")


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    raw, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)

    made = 0
    for locale, shots in CAPTIONS.items():
        for key, (l1, l2, palette) in shots.items():
            src = raw / f"{locale}-{key}.png"
            if not src.exists():
                print(f"  ! missing {src.name}, skipping")
                continue
            compose(src, l1, l2, palette, out / f"{locale}-{key}.png")
            made += 1
    print(f"{made} screenshots written to {out}")


if __name__ == "__main__":
    main()
