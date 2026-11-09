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

Output is 1320x2868 for the App Store Connect slot "iPhone with Dynamic Island
(large display)", plus a 1206x2622 copy of each shot (<name>-1206x2622.png) for
the "(medium display)" slot, which App Store Connect requires.
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1320, 2868
MEDIUM = (1206, 2622)
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
    medium = dest.with_name(dest.stem + "-1206x2622.png")
    canvas.resize(MEDIUM, Image.LANCZOS).save(medium, "PNG")
    print(f"  {medium.name}  ({MEDIUM[0]}x{MEDIUM[1]})")


# ---------------------------------------------------------------------------
# 1.2 store set: 10 shots per locale.
#
#   xcodebuild test -only-testing:TesserissUITests/ScreenshotTests/test_store_english \
#     -only-testing:TesserissUITests/ScreenshotTests/test_store_turkish \
#     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -resultBundlePath out.xcresult
#   xcrun xcresulttool export attachments --path out.xcresult --output-path raw/
#   (rename each attachment to its suggestedHumanReadableName)
#   python3 scripts/make_store_screenshots.py --store raw/ store_shots/
#
# Writes store_shots/<ASC locale>/NN.png at 1320x2868 (APP_IPHONE_67 slot).
# The app UI only exists in English and Turkish: tr uses the Turkish captures,
# every other locale the English ones. Captions: 2-4 words, big, high contrast.
# Never use the T-word anywhere (trademark).
# ---------------------------------------------------------------------------

JA_FONT = "/System/Library/Fonts/ヒラギノ角ゴシック W8.ttc"

INDIGO = (22, 38, 74)
CREAM = (244, 238, 226)
STYLES = {
    # background top, background bottom, caption colour
    "cream":  ((247, 242, 232), (233, 223, 203), INDIGO),
    "indigo": ((29, 53, 94), (14, 25, 48), CREAM),
    "night":  ((20, 22, 30), (6, 7, 10), CREAM),
}

# key -> (raw capture name without the "<ui>-" prefix, style)
STORE_SHOTS = [
    ("01", "s01-game-hokusai", "indigo"),
    ("02", "s02-fourline-hokusai", "cream"),
    ("03", "s03-ghost-classic", "indigo"),
    ("04", ["s04-mode-fast-classic", "s04-mode-og-classic", "s04-mode-hard-classic"], "cream"),
    ("05", "s05-menu-hokusai", "indigo"),
    ("06", "s06-night-hokusai", "night"),
    ("07", "s07-colorblind-classic", "cream"),
    ("08", "s08-stats-classic", "indigo"),
    ("09", "s09-guide-2", "cream"),
    ("10", "s06-night-classic", "night"),
]

STORE_CAPTIONS = {
    "en": ["Calm Block Puzzle", "Four Rows at Once", "See Where It Lands",
           "Three Ways to Play", "Hokusai's Great Wave", "Play by Night",
           "Color-Blind Friendly", "Track Your Stats", "Learn in Seconds",
           "No Ads. Plays Offline."],
    "tr": ["Sakin Blok Bulmaca", "Dört Sıra Birden", "Nereye Düşeceğini Gör",
           "Üç Farklı Mod", "Hokusai'nin Büyük Dalgası", "Gece Modu",
           "Renk Körü Dostu", "İlerlemeni Takip Et", "Saniyede Öğren",
           "Reklamsız, Çevrimdışı"],
    "fr": ["Block Puzzle Zen", "Quatre lignes d'un coup", "Voyez où elle tombe",
           "Trois modes de jeu", "La vague d'Hokusai", "Mode nuit",
           "Adapté aux daltoniens", "Suivez vos stats", "Facile à apprendre",
           "Sans pub, sans wifi"],
    "es": ["Juego de bloques zen", "Cuatro líneas de golpe", "Mira dónde cae",
           "Tres modos de juego", "La ola de Hokusai", "Modo noche",
           "Apto para daltónicos", "Sigue tus estadísticas", "Fácil de aprender",
           "Sin anuncios, sin internet"],
    "ja": ["落ちものパズル", "一気に4ライン消し", "落下地点が見える",
           "3つのモード", "和風の癒しゲーム", "ナイトモード",
           "色覚サポート", "記録をチェック", "すぐに覚えられる",
           "オフライン・広告なし"],
}

# Mode names under the three-phone shot, as the app shows them.
MODE_NAMES = {"en": ("Crack", "Tear", "Shatter"), "tr": ("Çatlak", "Yırtık", "Parçalanma")}

# App Store Connect locale -> caption set
ASC_LOCALES = {"en-US": "en", "en-GB": "en", "tr": "tr", "fr-FR": "fr",
               "es-ES": "es", "es-MX": "es", "ja": "ja"}

BEZEL = 26
SCREEN_RADIUS_FULL = 186   # iPhone 17 Pro Max display corner, px at 3x


def caption_font(lang, size):
    if lang == "ja":
        return ImageFont.truetype(JA_FONT, size)
    return load_font(size, "Heavy")


def gradient(top, bottom):
    g = Image.new("RGB", (1, H))
    for y in range(H):
        t = y / (H - 1)
        g.putpixel((0, y), tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)))
    return g.resize((W, H))


def wrap(draw, text, font, max_w):
    """Greedy word wrap; Japanese captions stay on one line (they are short)."""
    if " " not in text:
        return [text]
    words, lines, cur = text.split(), [], ""
    for w in words:
        trial = (cur + " " + w).strip()
        if draw.textlength(trial, font=font) <= max_w or not cur:
            cur = trial
        else:
            lines.append(cur)
            cur = w
    lines.append(cur)
    return lines


def balanced_lines(draw, text, font, max_w):
    """Wrap, then rebalance a two-line caption so neither line is a stub."""
    lines = wrap(draw, text, font, max_w)
    if len(lines) == 2:
        words = text.split()
        best = None
        for k in range(1, len(words)):
            a, b = " ".join(words[:k]), " ".join(words[k:])
            wa, wb = draw.textlength(a, font=font), draw.textlength(b, font=font)
            if max(wa, wb) <= max_w and (best is None or max(wa, wb) < best[0]):
                best = (max(wa, wb), [a, b])
        if best:
            lines = best[1]
    return lines


def draw_caption(canvas, text, lang, colour, top=90, zone=400, max_w=1160):
    draw = ImageDraw.Draw(canvas)
    size = 150
    while True:
        font = caption_font(lang, size)
        lines = balanced_lines(draw, text, font, max_w)
        line_h = int(size * 1.12)
        widest = max(draw.textlength(l, font=font) for l in lines)
        if len(lines) <= 2 and widest <= max_w and line_h * len(lines) <= zone:
            break
        size -= 4
    block_h = line_h * len(lines)
    y = top + (zone - block_h) // 2
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        x = (W - (bbox[2] - bbox[0])) // 2 - bbox[0]
        draw.text((x, y - bbox[1] + (line_h - (bbox[3] - bbox[1])) // 2), line,
                  font=font, fill=colour)
        y += line_h
    return size


def phone(shot, screen_w):
    """The capture in a black iPhone bezel with a Dynamic Island. RGBA."""
    scale = screen_w / shot.width
    sw, sh = screen_w, int(shot.height * scale)
    radius = int(SCREEN_RADIUS_FULL * scale)
    screen = shot.convert("RGB").resize((sw, sh), Image.LANCZOS)
    ow, oh = sw + 2 * BEZEL, sh + 2 * BEZEL
    body = Image.new("RGBA", (ow, oh), (0, 0, 0, 0))
    d = ImageDraw.Draw(body)
    d.rounded_rectangle([(0, 0), (ow - 1, oh - 1)], radius=radius + BEZEL, fill=(17, 17, 19, 255))
    # A faint rim so the bezel reads against the dark backgrounds too.
    d.rounded_rectangle([(1, 1), (ow - 2, oh - 2)], radius=radius + BEZEL,
                        outline=(90, 92, 100, 255), width=3)
    body.paste(screen, (BEZEL, BEZEL), rounded_mask((sw, sh), radius))
    iw, ih = int(375 * scale), int(111 * scale)
    ix, iy = (ow - iw) // 2, BEZEL + int(33 * scale)
    d.rounded_rectangle([(ix, iy), (ix + iw, iy + ih)], radius=ih // 2, fill=(0, 0, 0, 255))
    return body


def paste_with_shadow(canvas, layer, x, y, strength=95, blur=34, offset=24):
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    alpha = layer.split()[3].point(lambda a: strength if a else 0)
    shadow.paste((0, 0, 0, 255), (x, y + offset), alpha)
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(layer, (x, y))


def pill(canvas, text, cx, top, lang, style):
    fg = STYLES[style][2]
    bg = INDIGO if fg == CREAM else CREAM
    bg, fg = (fg, bg)  # pill is the caption colour, text the background colour
    size = 64 if len(text) <= 8 else 54
    font = load_font(size, "Heavy") if lang != "ja" else caption_font("ja", 60)
    d = ImageDraw.Draw(canvas)
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    pw, ph = tw + 76, th + 44
    x0 = min(max(cx - pw // 2, 30), W - 30 - pw)
    d.rounded_rectangle([(x0, top), (x0 + pw, top + ph)], radius=ph // 2, fill=bg + (255,))
    d.text((x0 + 38 - bbox[0], top + 22 - bbox[1]), text, font=font, fill=fg + (255,))


def compose_store(raw, ui, lang, key, src, style, text, dest):
    top, bottom, colour = STYLES[style]
    canvas = gradient(top, bottom).convert("RGBA")
    draw_caption(canvas, text, lang, colour, max_w=1060 if lang == "ja" else 1160)
    if isinstance(src, list):
        # Three modes: a descending cascade, left to right. Each phone covers only
        # the sidebar of the one before it, so all three boards stay in view.
        shots = [Image.open(raw / f"{ui}-{n}.png") for n in src]
        bodies = [phone(sh, 628) for sh in shots]
        xs, ys = (10, 440, 870), (620, 850, 1080)
        for body, x, y in zip(bodies, xs, ys):
            paste_with_shadow(canvas, body, x, y, strength=120)
        names = MODE_NAMES.get(ui, MODE_NAMES["en"])
        for name, x, y, body in zip(names, xs, ys, bodies):
            visible = min(x + body.width, W) if x == xs[-1] else x + (xs[1] - xs[0])
            pill(canvas, name, (x + visible) // 2, y + body.height + 44, ui, style)
    else:
        shot = Image.open(raw / f"{ui}-{src}.png")
        body = phone(shot, 1000)
        paste_with_shadow(canvas, body, (W - body.width) // 2, H - body.height - 70)
    out = canvas.convert("RGB")
    assert out.size == (W, H)
    out.save(dest, "PNG")


def main_store(raw, out):
    made = 0
    for asc_locale, lang in ASC_LOCALES.items():
        ui = "tr" if lang == "tr" else "en"
        folder = out / asc_locale
        folder.mkdir(parents=True, exist_ok=True)
        for (key, src, style), text in zip(STORE_SHOTS, STORE_CAPTIONS[lang]):
            compose_store(raw, ui, lang, key, src, style, text, folder / f"{key}.png")
            made += 1
        print(f"  {asc_locale}: 10 shots ({lang} captions, {ui} UI)")
    print(f"{made} screenshots written to {out}")



def main():
    if len(sys.argv) == 4 and sys.argv[1] == "--store":
        return main_store(pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3]))
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
    print(f"{made} screenshots (+ {made} 1206x2622 copies) written to {out}")


if __name__ == "__main__":
    main()
