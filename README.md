# Tesseriss

Minimalist falling-blocks puzzle for iOS. Comforting palette, big-button touch controls, three game modes, and an optional public-domain Impressionist piano playlist. Built in SwiftUI for iOS 17+.

The name is Greek *tesseris* ("four") + German *Riss* ("tear") — tear the rows four at a time.

## Highlights

- Three modes, chosen on the menu: **Crack** (8×15, faster gravity), **Tear** (10×20 classic — default), **Shatter** (10×20 with a 15 % chance of pentominoes).
- 7 tetrominoes + 4 pentominoes (U, P, +, F — Shatter only), fixed-table rotation, 7-bag randomizer, ghost piece.
- Table-based gravity (levels 0–19) → smooth saturation curve afterwards, scaled per mode.
- Scoring 100 / 300 / 1000 / 4000 × (level + 1) per cleared lines. Per-mode highscores.
- Four-line clear celebration: 500 ms pause + row flash + chime + success haptic.
- Two theme styles — **Classic** and **Kanagawa / Hokusai** (wooden board + Great Wave line-clear splash) — each with **Day / Night** appearance.
- Turkish + English in-app (default Turkish); all settings persisted in `UserDefaults`.
- Pause auto-fires on scene background; resume only via the explicit button.

## Audio

**Recordings are not committed to this repo.** The bundled sound effects (`line_clear.wav`, `four_line.wav`) are silent placeholders, and the music tracks are absent — so the game is silent until you supply your own files. Drop replacements into `TesserissApp/Resources/` and re-run `xcodegen generate`.

The Music toggle expects an 8-track Impressionist playlist (`MusicPlaylist.impressionists`). Source public-domain / CC-BY recordings (e.g. [Wikimedia Commons](https://commons.wikimedia.org/)), convert to `.m4a`/`.wav` (AVAudioPlayer can't decode `.ogg`: `ffmpeg -i in.ogg -c:a aac -b:a 192k out.m4a`), and name them exactly:

| File | Piece |
|---|---|
| `01_satie_gymnopedie_1` | Satie — Gymnopédie No. 1 |
| `02_satie_gymnopedie_3` | Satie — Gymnopédie No. 3 |
| `03_satie_gnossienne_1` | Satie — Gnossienne No. 1 |
| `04_satie_gnossienne_3` | Satie — Gnossienne No. 3 |
| `05_debussy_clair_de_lune` | Debussy — Clair de Lune |
| `06_debussy_reverie` | Debussy — Rêverie |
| `07_debussy_arabesque_1` | Debussy — Première Arabesque |
| `08_ravel_pavane` | Ravel — Pavane pour une infante défunte |

⚠️ **Licensing:** the compositions are out of copyright, but specific *recordings* may be **CC-BY** (e.g. a common Clair de Lune recording by Laurens Goedhart), which requires visible attribution. Verify each file's licence on its source page and credit performers on-screen before shipping.

## Build (CLI)

```bash
brew install xcodegen
xcodegen generate
xcodebuild \
  -project Tesseriss.xcodeproj \
  -scheme Tesseriss \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

## Test

```bash
xcodebuild test \
  -project Tesseriss.xcodeproj \
  -scheme Tesseriss \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

`TesserissTests` covers `Board`, `Tetromino`, `Scoring`, `GameMode`, and the 7-bag `Randomizer` (38 unit tests); `TesserissUITests` adds 8 XCUITests (menu/game/settings flow + seeded deterministic gameplay). CI runs both suites on every push and pull request (`.github/workflows/tests.yml`, macOS-15 runner).

## Run in Xcode

```bash
xcodegen generate
open Tesseriss.xcodeproj
```

Pick any iPhone simulator and ⌘R.

## Project layout

```
TesserissApp/
  TesserissApp.swift              // @main entry
  Models/                         // Tetromino (+ pentominoes), Board
  Engine/                         // GameEngine, GameState, GameMode, Scoring, Randomizer
  Services/                       // SettingsStore, HighscoreStore, AudioController,
                                  // HapticController, Strings (TR + EN), MusicPlaylist, Theme
  Views/                          // MenuView, GameView, ControlsView, CellView, PlayfieldView,
                                  // SettingsView, GameOverView, WoodenBoardView,
                                  // KanagawaBackgroundView, WaveSplashView
  Resources/                      // Assets.xcassets (incl. AppIcon), PrivacyInfo.xcprivacy,
                                  // placeholder .wav SFX
TesserissTests/                   // XCTest unit tests (Board, Tetromino, Scoring, GameMode, Randomizer)
TesserissUITests/                 // XCUITest UI tests
project.yml                       // XcodeGen source of truth (the .xcodeproj is generated, not committed)
.github/workflows/tests.yml       // CI
LICENSE                           // MIT
```

## License

[MIT](LICENSE).
