# Tesseriss — Handoff

iOS 17+, SwiftUI end-to-end, XcodeGen-managed. Bundle id `com.W00DSRULES.Tesseriss`.

---

## ✅ What's working

Core mechanics
- 10×20 board, 7-piece bag randomizer, gravity tick driven by `Scoring.gravityInterval(level:)` (classic table 0–19 then a saturation curve approaching 20 ms by level 60+).
- Single rotate button (CW); three taps = CCW. Move left / soft-drop / move right with hold-to-repeat (270 ms initial / 50 ms repeat). Hard drop locks instantly.
- Classic scoring 40 / 100 / 300 / 1200 × (level + 1). Soft drop awards +1 per cell while ▼ is held.
- Level rises +1 per 10 lines cleared; gravity shortens accordingly.
- Top-out game over fires on the spawn frame (era-classic-faithful).
- Ghost piece outlines the landing position; toggleable in Settings.

Visual / theme
- Comforting palette in `Assets.xcassets` with Day + Night variants for background / grid / ink / card colors.
- Grid lines visible on the playfield (0.5 pt per cell).
- Four-line clear: 500 ms gravity pause + row flash + chime + `.success` haptic. 1–3 line clears: 200 ms + soft flash + `.medium` haptic.
- Reduce Motion respected on the celebration's screen-pulse.

I18n
- Default language **Turkish**; English available via Settings → 🌐 Dil picker. Persisted in `UserDefaults`.
- All UI labels, About paragraph, and the menu scoring hint (1 sıra · 40, …, 4 sıra · 1200 ★) localize.

Settings
- Emoji-prefixed rows: 🎵 Müzik · 📳 Titreşim · 👻 Gölge · 🎨 Tema (☀️ Gündüz | 🌙 Gece) · 🌐 Dil.
- All toggles + pickers persisted in `UserDefaults`.

Pause / lifecycle
- Pause icon (⏸) in the GameView header, disabled while paused.
- Paused overlay has a primary **RESUME** button and a secondary **MENU** button.
- `scenePhase` observer auto-pauses on background / Control Center; resume requires an explicit tap.

Persistence
- Highscore in `UserDefaults` (`tesseriss.highscore`) — shown on menu and game-over screen with a "NEW BEST" badge.

Tests
- `TesserissTests` covers Board (8 tests), Tetromino (5), Scoring (6), Randomizer (4) — 23 unit tests, all pure-Swift, run in <50 ms.
- CI runs on every push via `.github/workflows/tests.yml` (macOS-15 runner).

---

## 🛠️ Manual action needed

1. **Music playlist** — `AudioController` now expects 8 bundled tracks (see §🎼 Music playlist below). None are bundled — the Music toggle is a no-op until you drop them in. Format: any of `.m4a`, `.mp3`, `.wav`, `.caf`, `.aiff`, `.flac`.
2. **SFX placeholders** — `line_clear.wav` and `four_line.wav` ship as silent WAVs. Replace with CC0 recordings (Pixabay / Freesound).
2. **Apple Developer signing** — `project.yml` disables code signing for simulator (`CODE_SIGN_IDENTITY = "-"`, empty `DEVELOPMENT_TEAM`). Set your Team ID and re-enable automatic signing for device / TestFlight / App Store.
3. **App icon** — `Assets.xcassets/AppIcon.appiconset/AppIcon.png` is a 1024×1024 lavender T-piece placeholder. Replace before submitting.
4. **Real-device haptics check** — simulator haptics are no-ops. Verify `.light` / `.medium` / `.success` / `.error` feel right on a physical iPhone.
5. **App Store submission** — none of the App Store Connect / TestFlight / privacy-policy steps are done; the codebase just compiles and tests cleanly.
6. **Extended features** — not implemented: starting-level picker, Stats page, Daily challenge. iCloud KVS sync intentionally out of scope (local-only highscore by design). The base architecture leaves room (`GameEngine.init` can take an optional `startLevel` etc.).

---

## ▶️ Build, test, run

Prereqs: Xcode 26+ installed at `/Applications/Xcode.app`; license accepted (`sudo xcodebuild -license accept`). On a fresh Mac the iOS Simulator runtime is downloaded on first use (~8.5 GB).

```bash
brew install xcodegen
xcodegen generate
```

**Build for simulator:**
```bash
xcodebuild \
  -project Tesseriss.xcodeproj \
  -scheme Tesseriss \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

**Run unit tests:**
```bash
xcodebuild test \
  -project Tesseriss.xcodeproj \
  -scheme Tesseriss \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

**Boot a simulator and launch:**
```bash
xcrun simctl boot 'iPhone 16' 2>/dev/null || true
open -a Simulator
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/Tesseriss-*/Build/Products/Debug-iphonesimulator/Tesseriss.app
xcrun simctl launch booted com.W00DSRULES.Tesseriss
```

Or just `open Tesseriss.xcodeproj` and ⌘R.

---

## 🎼 Music — Playlist 1: Impressionists

Playlists are now a first-class concept (`MusicPlaylist` in `Services/`). The active playlist id is persisted as `tesseriss.settings.playlist`; defaults to `impressionists`. `AudioController` reloads tracks if the id changes, so swapping playlists is a single setter.

**Playlist 1** is ~31 min, Satie / Debussy / Ravel — all compositions out of copyright. Drop these files into `TesserissApp/Resources/` with the exact filenames in the **Filename** column, then re-run `xcodegen generate`. Volume is fixed at 0.5; audio session is `.ambient` + `.mixWithOthers`.

| # | Composer · Piece | Approx. duration | Filename | Source | License |
|---|---|---|---|---|---|
| 1 | Satie — Gymnopédie No. 1 (Robin Alciatore) | 3:04 | `01_satie_gymnopedie_1` | [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Erik_Satie_-_gymnopedies_-_la_1_ere._lent_et_douloureux.ogg) | Public domain (released by performer) |
| 2 | Satie — Gymnopédie No. 3 | ~2:30 | `02_satie_gymnopedie_3` | [Wikimedia Commons: Gymnopédie No. 3](https://commons.wikimedia.org/wiki/Category:Gymnop%C3%A9dies_(Satie)) | Pick a PD entry from the category page |
| 3 | Satie — Gnossienne No. 1 | 3:38 | `03_satie_gnossienne_1` | [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Satie_-_Gnossienne_1.ogg) | Public Domain Mark + CC BY-SA 3.0 |
| 4 | Satie — Gnossienne No. 3 | ~3:00 | `04_satie_gnossienne_3` | [Wikimedia Commons: Gnossienne 3 (Satie)](https://commons.wikimedia.org/wiki/File:Gnossienne_3_(Satie).ogg) | Public Domain Mark |
| 5 | Debussy — Clair de Lune (Laurens Goedhart) | 5:04 | `05_debussy_clair_de_lune` | [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Clair_de_lune_(Claude_Debussy)_Suite_bergamasque.ogg) | **CC BY 3.0 — credit Laurens Goedhart** |
| 6 | Debussy — Rêverie | ~4:30 | `06_debussy_reverie` | [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Reverie.ogg) | Public Domain Mark |
| 7 | Debussy — Première Arabesque (Patrizia Prati) | ~4:30 | `07_debussy_arabesque_1` | [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Claude_Debussy_-_Premi%C3%A8re_Arabesque_-_Patrizia_Prati.ogg) | Verify on file page before shipping |
| 8 | Ravel — Pavane pour une infante défunte (Thérèse Dussaut) | ~6:00 | `08_ravel_pavane` | [Wikimedia file](https://en.wikipedia.org/wiki/File:Maurice_Ravel_-_Th%C3%A9r%C3%A8se_Dussaut_-_Pavane_pour_une_infante_d%C3%A9funte.ogg) | Verify on file page before shipping |

**Conversion**: AVAudioPlayer doesn't decode `.ogg`, so convert each download to `.m4a` (AAC) or `.wav`. With ffmpeg:

```bash
for f in *.ogg; do ffmpeg -i "$f" -c:a aac -b:a 192k "${f%.ogg}.m4a"; done
```

Or macOS-native (no ffmpeg needed) — decode .ogg via Audacity first, then `afconvert input.wav output.m4a -d aac -f m4af -b 192000`.

**Attribution**: at minimum credit the named performers on a Credits / About screen for any CC-BY track. Public-domain tracks don't require attribution but it's polite.

### Adding a Playlist 2

1. Append a `static let yourID = MusicPlaylist(...)` to `MusicPlaylist+Catalog` and add it to `MusicPlaylist.all`.
2. Add the audio files to `TesserissApp/Resources/` (or tag them as On-Demand Resources — see below).
3. Either set `settings.playlistID` programmatically, or add a picker to `SettingsView` (`Picker(...)` bound to `$settings.playlistID`).

### Cost / storage of more music

App-side bundle math at AAC 128 kbps:

| Music duration | Approx bundle add |
|---|---|
| 30 min | ~30 MB |
| 60 min | ~60 MB |
| 90 min | ~90 MB |

App Store thresholds to keep in mind:
- **< 200 MB** total install — required for "Allow downloads over cellular" without a friction prompt; above that, users only download on Wi-Fi.
- **< 30 MB** is the sweet spot for impulse installs from the App Store list.
- **4 GB hard cap** on a single iOS app (you're nowhere near this).

Where to store track bytes — three reasonable options for this app:

1. **Bundle them in the app** (simplest). Each playlist adds ~30 MB. Fine for one or two playlists; gets noticed past ~100 MB total install.
2. **On-Demand Resources (ODR)** — Apple's official answer. Tag each playlist's files in Xcode with a string tag, then `NSBundleResourceRequest(tags:)` downloads them from Apple's CDN the first time a player picks that playlist. Apple hosts; no bandwidth bill. Caps: 2 GB initial install footprint + 20 GB total. Adds a one-time "downloading…" UX you'll need to handle.
3. **Your own CDN** (CloudKit asset, Cloudflare R2, S3). Cheapest at scale (~$0.015/GB/month + bandwidth) and lets you swap playlists without a binary update. Adds privacy-policy and reliability concerns; the app needs network code.

For Tesseriss, the bundle (option 1) is the right answer until you're past ~3 playlists or ~90 MB. After that, ODR is the cleanest next step — same App Store distribution, no server work.

## 📋 Known gaps

- Silent audio. The wiring is correct; you'll hear it the moment you swap the WAV bytes.
- No UI XCUITests yet (only unit tests).
- No SwiftUI previews (intentional — kept out of scope).
- Bundle ID is `com.W00DSRULES.Tesseriss`. If you ever need to change it, edit `project.yml` and re-run `xcodegen generate`.
- Rotation uses fixed 4-state tables without SRS wall kicks — classic-era, intentional.
- Four-line celebration row-flash is single-pass; a two-cycle flash with a screen pulse on the whole view would be a polish step (currently only the playfield scales).
- Backgrounding *during* a Four-line celebration: the clear timer keeps running on background; when you foreground, the celebration may already be over. Cosmetic, not a correctness bug.
- Status bar style is fixed to `UIStatusBarStyleDefault`; iOS should pick light content automatically in Night mode via `preferredColorScheme`, but worth verifying on hardware.
- Dynamic Type not yet supported (fonts use literal sizes).
- VoiceOver — buttons are icon-only with no accessibility labels.
