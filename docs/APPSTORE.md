# App Store listing — Tesseriss

Copy-ready metadata for App Store Connect. Two locales: **English (en-US, primary)** and **Turkish (tr)**.
Character limits noted in parentheses — App Store Connect enforces them.

> ⚠️ **Trademark note:** never use the word "Tetris" anywhere in the name, subtitle, keywords, or
> description. It's a registered trademark of The Tetris Company, which actively polices the store.
> Use "falling blocks", "tetromino", "block puzzle" instead. (The repo already did this distancing.)

---

## English (en-US)

**App Name** (≤30) — `Tesseriss`

**Subtitle** (≤30) — `A calm falling-blocks puzzle`

**Promotional text** (≤170, editable anytime without review)
> Stack the tetrominoes, try to tear four rows at once, and settle into a comforting palette with
> calm classical music. No ads, no accounts, fully offline.

**Keywords** (≤100, comma-separated, no spaces after commas to save room)
`falling blocks,tetromino,block puzzle,line clear,arcade,calm,minimal,zen,relax,offline,puzzle`

**Description** (≤4000)
```
Tesseriss is a minimalist falling-blocks puzzle built for calm, focused play.

The name says what you do: tesseris (Greek, "four") + Riss (German, "tear") — tear the rows, four at a time.

Three modes, one tap apart:
– Crack (fast) — a smaller board and a quicker fall, for short, sharp sessions.
– Tear (og) — the classic board, the classic pace.
– Shatter (hard) — the classic board, but five-square pieces sneak into the mix.

Classic-arcade feel: a 7-bag piece randomizer, fixed rotation tables, a ghost piece showing where the block will land, and a four-line clear worth 4000 points — with a satisfying flash and chime.

Made to be looked at: a soft, comforting palette with Day and Night appearances, plus an optional Hokusai "Great Wave" theme.

A quiet soundtrack: classical piano by Satie and Debussy — toggle it on or off.

Yours, privately: highscores are stored only on your device. No ads, no accounts, no tracking, and it works completely offline.

Turkish and English, switchable in Settings.
```

**Support URL** — `https://w00dsrules.github.io/Tesseriss/support.html`
**Marketing URL** (optional) — `https://w00dsrules.github.io/Tesseriss/`
**Privacy Policy URL** — `https://w00dsrules.github.io/Tesseriss/privacy.html`
**Copyright** — `2026 Vibalyze OÜ`
**Category** — Primary: Games → Puzzle · Secondary (optional): Games → Arcade

---

## Turkish (tr)

**Uygulama adı** (≤30) — `Tesseriss`

**Alt başlık** (≤30) — `Sakin bir blok bulmacası`

**Tanıtım metni** (≤170)
> Tetrominoları üst üste diz, dört sırayı tek hamlede yırtmayı dene; sakin klasik müzik ve göz
> yormayan bir paletin tadını çıkar. Reklamsız, hesapsız, tamamen çevrimdışı.

**Anahtar kelimeler** (≤100)
`düşen bloklar,tetromino,blok bulmaca,sıra temizleme,arcade,sakin,minimal,zen,rahatlatıcı,çevrimdışı`

**Açıklama** (≤4000)
```
Tesseriss, sakin ve odaklanmış oyun için tasarlanmış minimalist bir düşen-blok bulmacası.

İsmi ne yapacağını söylüyor: tesseris (Yunanca "dört") + Riss (Almanca "yırtık") — sıraları dörder dörder yırt.

Üç mod, tek dokunuş uzakta:
– Çatlak (hızlı) — daha küçük tahta, daha hızlı düşüş; kısa ve keskin oyunlar için.
– Yırtık (klasik) — bildiğin tahta, bildiğin tempo.
– Parçalanma (zor) — klasik tahtaya beş kareli parçalar karışıyor.

Klasik arcade hissi: 7'li torba sistemi, sabit dönüş tabloları, parçanın nereye oturacağını gösteren gölge parça ve tek seferde dört sıra silmenin 4000 puanlık ödülü — parlamasıyla, çınlamasıyla.

Bakması da keyifli: Gündüz ve Gece görünümleriyle yumuşak, göz yormayan bir palet; dileyene Hokusai'nin "Büyük Dalga" teması.

Sessiz bir fon müziği: Satie ve Debussy'den klasik piyano — dilediğinde aç, dilediğinde kapat.

Senin, sana özel: rekorlar yalnızca cihazında saklanır. Reklam yok, hesap yok, takip yok; tamamen çevrimdışı çalışır.

Türkçe ve İngilizce — Ayarlar'dan tek dokunuşla.
```

---

## App Privacy (nutrition label) answers
- **Data collection:** select **"Data Not Collected."** (Highscore lives in local `UserDefaults`; no
  analytics, no network calls. Matches `PrivacyInfo.xcprivacy`.)

## Age rating
- Expected **4+** — no objectionable content, no web, no user-generated content, no gambling.

## Export compliance
- Already declared in-binary: `ITSAppUsesNonExemptEncryption = false` → no per-build prompt.
