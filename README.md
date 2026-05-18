# Tesseriss

Minimalist falling-blocks puzzle for iOS. Comforting palette, big-button touch controls, NES scoring, public-domain Impressionist piano loop. Built in SwiftUI for iOS 17+.

The name is Greek *tesseris* ("four") + German *Riss* ("tear") — tear the rows four at a time.

## Highlights

- 10×20 grid, NES-style rotation tables, 7-bag randomizer, ghost piece.
- NES gravity table (levels 0–19) → smooth saturation curve afterwards.
- Scoring 100 / 300 / 1000 / 4000 × (level + 1) per cleared lines.
- Tetris (4-line) celebration: 500 ms pause + row flash + chime + success haptic.
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
PLAN.md                           // original 5-week plan
HANDOFF.md                        // current state + what needs manual action
LICENSE                           // MIT
```

## TestFlight / App Store

The repo ships an archive + upload pipeline that does not bake any team-specific values into git.

**One-time setup (web):**

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/enroll/) (skip if already enrolled).
2. Create an App Store Connect API key at [Users and Access -> Integrations -> App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api). Role `Developer` or `App Manager`. Download the `.p8` once (Apple never shows it again). Note the Key ID and Issuer ID.

**Per-clone setup (CLI):**

1. `cp .env.local.example .env.local` and fill in `TEAM_ID`, `BUNDLE_ID`, `ASC_API_KEY_ID`, `ASC_API_ISSUER_ID`, `ASC_API_KEY_PATH`, and optionally `MARKETING_VERSION` / `BUILD_NUMBER`.
2. Save the `.p8` to the path you put in `ASC_API_KEY_PATH` (e.g. `./private_keys/AuthKey_XXXXXXXXXX.p8`).
3. `./scripts/bootstrap-app.sh` — registers the Bundle ID, creates the App Store Connect app record, then archives and uploads to TestFlight. Idempotent: re-runs only do the missing steps.

Or run the steps individually:
- `./scripts/archive.sh` -> `build/Tesseriss.xcarchive` + `build/export/Tesseriss.ipa`.
- `./scripts/upload-testflight.sh` -> validates and uploads via `xcrun altool`.

The Release configuration in `project.yml` signs with `Apple Distribution` via automatic signing; the archive script injects `DEVELOPMENT_TEAM` and the build number at xcodebuild invocation time. Debug builds keep the original simulator-only no-signing path.

## License

[MIT](LICENSE).
