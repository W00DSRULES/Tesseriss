# Tesseriss

Minimalist falling-blocks puzzle for iOS. Comforting palette, big-button touch controls, three game modes, and an optional Impressionist playlist (Satie and Debussy, mostly piano). Built in SwiftUI for iPhone only (portrait, iOS 17+); on iPad it runs in iPhone compatibility mode.

The name is Greek *tesseris* ("four") + German *Riss* ("tear") — tear the rows four at a time.

## Highlights

- Three modes, chosen on the menu: **Crack** (8×15, faster gravity), **Tear** (10×20 classic — default), **Shatter** (10×20 with a 15 % chance of pentominoes).
- 7 tetrominoes + 4 pentominoes (U, P, +, F — Shatter only), fixed-table rotation, 7-bag randomizer, ghost piece.
- Table-based gravity (levels 0–19) → smooth saturation curve afterwards, scaled per mode.
- Scoring 100 / 300 / 1000 / 4000 × (level + 1) per cleared lines. Per-mode highscores.
- **Daily challenge**: one Tear run per UTC day with the same pieces for every player (seeded from the date). Unlimited attempts; today's best and a day streak are kept apart from the mode highscores. Resets at 00:00 UTC.
- A 3-step **How to play** on first launch (skippable, reopened from Settings) and a **Stats** panel in Settings: games played, rows cleared, four-row clears, best per mode, current and longest daily streak.
- Four-line clear celebration: 500 ms pause + row flash + chime + success haptic.
- Two theme styles — **Classic** and **Kanagawa / Hokusai** (wooden board + Great Wave line-clear splash) — each with **Day / Night** appearance.
- Turkish + English in-app (first launch follows the device language); all settings persisted in `UserDefaults`.
- Pause auto-fires on scene background; resume only via the explicit button.

## Audio

The Music toggle plays a 6-track Impressionist playlist (`MusicPlaylist.impressionists`), bundled in `TesserissApp/Resources/`. **Every track is Public Domain, CC0, or Pixabay Content License — none requires attribution.** (The two sound effects, `line_clear.wav` and `four_line.wav`, are synthesised by `scripts/make_sfx.py`; re-run it to retune them. They have their own Sound effects toggle and volume slider in Settings, separate from Music's.)

| File | Piece | Instrument | Source / licence |
|---|---|---|---|
| `01_satie_gymnopedie_1.mp3` | Satie — Gymnopédie No. 1 | piano | Robin Alciatore · Public Domain |
| `02_satie_gnossienne_3.mp3` | Satie — Gnossienne No. 3 | piano | GregorQuendel · Pixabay |
| `03_debussy_clair_de_lune.mp3` | Debussy — Clair de Lune | piano | "1905 solo" · Public Domain Mark |
| `05_debussy_reverie.mp3` | Debussy — Rêverie | piano | Anonymous · Public Domain Mark |
| `06_satie_gymnopedie_3.mp3` | Satie — Gymnopédie No. 3 | piano | Teknopazzo · CC0 |
| `07_debussy_clair_de_lune_brass.mp3` | Debussy — Clair de Lune | brass | USAF Band of Flight · Public Domain |

Slot `04` (a harp Gymnopédie 1) is intentionally unused. To add or swap a track, drop a file into `Resources/` (`.m4a`/`.mp3`/`.wav`/`.caf`/`.aiff`/`.flac`; convert `.ogg`/`.opus` first with `ffmpeg -i in.ogg -c:a aac -b:a 192k out.m4a`), add its basename to `MusicPlaylist.swift`, and re-run `xcodegen generate`. If you swap in a different recording, re-check *its* licence — many Creative Commons performances are **CC-BY** (attribution) or **CC BY-NC/ND** (unusable in a commercial app).

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

`TesserissTests` covers `Board`, `Tetromino`, `Scoring`, `GameMode`, `GameEngine`, `SettingsStore`, `HighscoreStore` (stats, daily best and streak), the 7-bag `Randomizer`, the daily seed and the piece palettes (113 unit tests); `TesserissUITests` adds 29 XCUITests (menu/game/settings flow, onboarding, daily challenge, stats, seeded deterministic gameplay, and accessibility audits of each screen). `ScreenshotTests` captures the App Store screenshots and is skipped in CI. CI runs both suites on every push and pull request with code coverage on, and fails if line coverage drops below set floors (`.github/workflows/tests.yml`, macOS-15 runner). CI selects Xcode 26 or later and an iPhone 17 simulator, the setup the accessibility audits were tuned on.

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
  Engine/                         // GameEngine, GameState, GameMode, Scoring, Randomizer (+ DailyChallenge)
  Services/                       // SettingsStore, HighscoreStore, AudioController,
                                  // HapticController, Strings (TR + EN), MusicPlaylist, Theme
  Views/                          // MenuView, GameView, ControlsView, CellView, PlayfieldView,
                                  // SettingsView, GameOverView, WoodenBoardView,
                                  // KanagawaBackgroundView, WaveSplashView, OnboardingView
  Resources/                      // Assets.xcassets (incl. AppIcon), PrivacyInfo.xcprivacy,
                                  // line-clear .wav SFX (scripts/make_sfx.py)
TesserissTests/                   // XCTest unit tests (Board, Tetromino, Scoring, GameMode, GameEngine,
                                  // SettingsStore + HighscoreStore, Randomizer + DailyChallenge)
TesserissUITests/                 // XCUITest UI tests
project.yml                       // XcodeGen source of truth (the .xcodeproj is generated, not committed)
.github/workflows/tests.yml       // CI
LICENSE                           // MIT
```

## License

[MIT](LICENSE).
