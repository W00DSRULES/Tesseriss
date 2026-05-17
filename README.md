# TesseraRiss

Minimalist falling-blocks puzzle for iOS. Comforting palette, big-button touch controls, NES scoring, *Korobeiniki* loop. Built in SwiftUI for iOS 17+.

The name is Latin *tessera* ("four-sided tile") + German *Riss* ("tear") — "tear the tiles".

## Highlights

- 10×20 grid, SRS rotation tables, 7-bag randomizer, ghost piece.
- NES gravity table (levels 0–19) → smooth saturation curve afterwards.
- Tetris (4-line) celebration: 500 ms pause + row flash + chime + success haptic.
- Day / Night theme, Turkish + English in-app, persisted in `UserDefaults`.
- Pause auto-fires on scene background; resume only via the explicit button.

## Build (CLI)

```bash
brew install xcodegen
xcodegen generate
xcodebuild \
  -project TesseraRiss.xcodeproj \
  -scheme TesseraRiss \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

## Test

```bash
xcodebuild test \
  -project TesseraRiss.xcodeproj \
  -scheme TesseraRiss \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

`TesseraRissTests` covers `Board`, `Tetromino`, `Scoring`, and the 7-bag `Randomizer`. CI runs on every push (`.github/workflows/tests.yml`, macOS-15 runner).

## Run in Xcode

```bash
xcodegen generate
open TesseraRiss.xcodeproj
```

Pick any iPhone simulator and ⌘R.

## Project layout

```
TesseraRissApp/
  TesseraRissApp.swift            // @main entry
  Models/                         // Tetromino, Board
  Engine/                         // GameEngine, GameState, Scoring, Randomizer
  Services/                       // SettingsStore, HighscoreStore, AudioController,
                                  // HapticController, Strings (TR + EN)
  Views/                          // MenuView, GameView, ControlsView, CellView,
                                  // PlayfieldView, SettingsView, GameOverView
  Resources/                      // Assets.xcassets, placeholder .wav audio
TesseraRissTests/                 // XCTest unit tests
project.yml                       // XcodeGen source of truth
.github/workflows/tests.yml       // CI
PLAN.md                           // original 5-week plan
HANDOFF.md                        // current state + what needs manual action
LICENSE                           // MIT
```

## License

[MIT](LICENSE).
