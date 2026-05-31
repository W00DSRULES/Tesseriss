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
> Three speeds, one quiet board. Stack the tetrominoes, tear four rows at once, and settle into a
> comforting palette with public-domain piano. No ads, no accounts, fully offline.

**Keywords** (≤100, comma-separated, no spaces after commas to save room)
`falling blocks,tetromino,block puzzle,brick,line clear,arcade,calm,minimal,zen,relax,classic,piano,offline,puzzle`

**Description** (≤4000)
```
Tesseriss is a minimalist falling-blocks puzzle built for calm, focused play.

The name says what you do: tesseris (Greek, "four") + Riss (German, "a tear") — tear the rows, four
at a time.

• Three modes, one tap apart:
  – Crack (fast) — a quicker fall for short, sharp sessions.
  – Tear (og) — the classic 10×20 pace.
  – Shatter (hard) — for when you want the floor to come up fast.

• Classic-era feel: 7-bag piece randomizer, fixed rotation tables, a ghost piece showing where the
  block will land, and a four-line clear worth 4000 points with a satisfying flash and chime.

• Made to be looked at: a soft, comforting palette with Day and Night appearances, plus an optional
  Hokusai "Great Wave" theme.

• A quiet soundtrack: public-domain piano from Satie, Debussy, and Ravel — toggle it on or off.

• Yours, privately: highscores are stored only on your device. No ads, no accounts, no tracking,
  and it works completely offline.

• Turkish and English, switchable in Settings.

Stack, clear, breathe. Tear the rows.
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
> Üç hız, tek bir sakin tahta. Blokları diz, dört sırayı birden yırt; huzurlu bir paletle ve kamu
> malı piyano eşliğinde dinlen. Reklam yok, hesap yok, tamamen çevrimdışı.

**Anahtar kelimeler** (≤100)
`düşen bloklar,tetromino,blok bulmaca,tuğla,sıra,arcade,sakin,minimal,zen,rahatlatıcı,klasik,piyano,çevrimdışı`

**Açıklama** (≤4000)
```
Tesseriss, sakin ve odaklı bir oyun için tasarlanmış minimalist bir düşen-blok bulmacasıdır.

Adı, ne yaptığını anlatır: tesseris (Yunanca, "dört") + Riss (Almanca, "yırtık") — sıraları dörder
dörder yırt.

• Bir dokunuş ötede üç mod:
  – Çatlak (hızlı) — kısa ve keskin oyunlar için daha hızlı bir düşüş.
  – Yırtık (klasik) — klasik 10×20 tempo.
  – Parçalanma (zor) — zemin hızla yükselsin istediğinde.

• Klasik dokunuş: 7'li torba rastgeleleştirici, sabit döndürme tabloları, bloğun nereye ineceğini
  gösteren gölge parça ve 4000 puanlık dört-sıra temizliği — tatmin edici bir parlama ve çınlama ile.

• Bakmak için yapıldı: Gündüz ve Gece görünümleriyle huzur veren bir palet, ayrıca isteğe bağlı
  Hokusai "Muhteşem Dalga" teması.

• Sessiz bir müzik: Satie, Debussy ve Ravel'den kamu malı piyano — istediğin gibi aç ya da kapat.

• Sana özel: rekorlar yalnızca cihazında saklanır. Reklam yok, hesap yok, takip yok ve tamamen
  çevrimdışı çalışır.

• Türkçe ve İngilizce, Ayarlar'dan değiştirilebilir.

Diz, temizle, nefes al. Sıraları yırt.
```

---

## App Privacy (nutrition label) answers
- **Data collection:** select **"Data Not Collected."** (Highscore lives in local `UserDefaults`; no
  analytics, no network calls. Matches `PrivacyInfo.xcprivacy`.)

## Age rating
- Expected **4+** — no objectionable content, no web, no user-generated content, no gambling.

## Export compliance
- Already declared in-binary: `ITSAppUsesNonExemptEncryption = false` → no per-build prompt.
