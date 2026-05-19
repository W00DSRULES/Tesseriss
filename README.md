# Tesseriss

Minimalist falling-blocks puzzle for iOS. Comforting palette, big-button touch controls, classic-era scoring, public-domain Impressionist piano loop. Built in SwiftUI for iOS 17+.

The name is Greek *tesseris* ("four") + German *Riss* ("tear") — tear the rows four at a time.

## Highlights

- 10×20 grid, classic-era rotation tables, 7-bag randomizer, ghost piece.
- Table-based gravity (levels 0–19) → smooth saturation curve afterwards.
- Scoring 100 / 300 / 1000 / 4000 × (level + 1) per cleared lines.
- Four-line clear celebration: 500 ms pause + row flash + chime + success haptic.
- Day / Night theme, Turkish + English in-app, persisted in `UserDefaults`.
- Pause auto-fires on scene background; resume only via the explicit button.

## Build (CLI)

```bash
brew install xcodegen
xcodegen generate
xcodebuild \
  -project Tesseriss.xcodeproj \
  -scheme Tesseriss \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

## Test

```bash
xcodebuild test \
  -project Tesseriss.xcodeproj \
  -scheme Tesseriss \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

`TesserissTests` covers `Board`, `Tetromino`, `Scoring`, and the 7-bag `Randomizer`. CI runs on every push (`.github/workflows/tests.yml`, macOS-15 runner).

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
  Models/                         // Tetromino, Board
  Engine/                         // GameEngine, GameState, Scoring, Randomizer
  Services/                       // SettingsStore, HighscoreStore, AudioController,
                                  // HapticController, Strings (TR + EN), MusicPlaylist
  Views/                          // MenuView, GameView, ControlsView, CellView,
                                  // PlayfieldView, SettingsView, GameOverView
  Resources/                      // Assets.xcassets, placeholder .wav audio
TesserissTests/                   // XCTest unit tests
project.yml                       // XcodeGen source of truth
.github/workflows/tests.yml       // CI
docs/HANDOFF.md                   // current state + what needs manual action
LICENSE                           // MIT
```

## License

[MIT](LICENSE).
