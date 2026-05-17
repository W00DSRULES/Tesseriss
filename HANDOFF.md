# TesseraRiss — Handoff

A minimalist falling-blocks iOS game scaffolded per `PLAN.md`. iOS 17+, SwiftUI end-to-end, XcodeGen-managed project, single-rotation big-button controls.

---

## ✅ What's working

Core mechanics
- 10×20 board, 7-piece bag randomizer, gravity tick driven by `Scoring.gravityInterval(level:)` (NES table 0–19 then a saturation curve to ~20ms by level 60+).
- Single rotate button (CW); three taps = CCW. Move left / soft-drop / move right with hold-to-repeat (270 ms initial delay, 50 ms repeat). Hard drop locks instantly.
- NES scoring: single = 40, double = 100, triple = 300, tetris = 1200, all × `(level + 1)`. Soft drop awards +1 per cell while ▼ is held.
- Level rises +1 per 10 lines cleared; gravity interval shortens accordingly.
- Top-out game-over fires on the spawn frame if the spawned piece overlaps existing blocks (NES-faithful, no upward nudge).

Tetris celebration
- 500 ms gravity pause on 4-line clears; rows flash white over the palette color; warm chime SFX (placeholder) + `.success` haptic.
- 200 ms pause + soft flash + `line_clear` SFX (placeholder) + `.medium` haptic on 1–3 line clears.
- Reduce Motion suppresses the screen-pulse on celebrations (row flash still fires).

Audio + haptics
- `AVAudioPlayer` with session category `.ambient` + `.mixWithOthers` so it never ducks the user's other audio.
- Music loop (placeholder silent WAV) at ~0.5 volume; SFX players preloaded for line clear + tetris chime.
- Haptics use `UIImpactFeedbackGenerator` (light on move, medium on lock) and `UINotificationFeedbackGenerator` (success on tetris, error on game-over).

Persistence + settings
- Highscore stored in `UserDefaults` (`tesserariss.highscore`) and reflected on the menu + game-over screen with a "NEW BEST" badge.
- Settings toggles for Music and Haptics, persisted in `UserDefaults` (`tesserariss.settings.music` / `.haptics`).

Pause + lifecycle
- Pause button in the GameView header; `scenePhase` observer auto-pauses on background / Control Center / etc. Resume requires an explicit tap (no surprise drops on app re-open).

Visuals
- Comforting cream-and-muted palette wired through `Assets.xcassets` as named colors (`PaletteBackground`, `PieceI` … `PieceJ`).
- Solid-color inner-border block style, SF Pro Rounded throughout. App icon is a lavender T-piece on cream — placeholder for week-5 redesign.

---

## 🛠️ Manual action needed

1. **Real audio (CC0)** — the bundled `korobeiniki.wav`, `line_clear.wav`, `tetris.wav` are all silent placeholders. Replace with licensed CC0 / public-domain recordings (Pixabay or FreeMusicArchive for Korobeiniki; Pixabay / Freesound for SFX). Keep the same filenames or update `AudioController.preload()`. PLAN.md prefers `.m4a` for music and `.caf` for SFX — you can swap the extensions there if you re-encode.
2. **Apple Developer signing** — `project.yml` disables code signing for the simulator workflow (`CODE_SIGN_IDENTITY = "-"`, `CODE_SIGNING_REQUIRED = NO`, empty `DEVELOPMENT_TEAM`). To run on a real device or submit to App Store Connect, set `DEVELOPMENT_TEAM` to your Team ID and re-enable automatic code signing, then `xcodegen generate`.
3. **App icon** — `Assets.xcassets/AppIcon.appiconset/AppIcon.png` is a 1024×1024 placeholder (lavender T-piece on cream, no wordmark — wordmark felt cramped at that scale). Replace with your final design before App Store submission.
4. **Real-device haptics check** — simulator haptics are no-ops. Verify on a physical iPhone that `.light` / `.medium` / `.success` / `.error` feel right.
5. **App Store enrollment + submission** — none of the App Store Connect / TestFlight / privacy-policy steps in PLAN.md were done; the codebase is just ready to be opened in Xcode.
6. **Extended v1 features** (per PLAN.md week 4) — not implemented: starting-level picker, Stats page, Daily challenge, iCloud KVS sync, full XCTest / XCUITest suite. The base game architecture leaves room for these; `GameEngine.init` can take an optional `startLevel` parameter when you wire the picker.

---

## ▶️ Build and run

Prerequisite: Xcode 26+ installed at `/Applications/Xcode.app`. Xcode license has been accepted (`sudo xcodebuild -license accept`).

Two ways to work with the project:

**A. Xcode UI**

```
xcodegen generate         # regenerate after any project.yml edit
open TesseraRiss.xcodeproj
```

Pick an iPhone simulator scheme and ⌘R to run.

**B. Command line**

```bash
xcodegen generate
xcodebuild \
  -project TesseraRiss.xcodeproj \
  -scheme TesseraRiss \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

xcrun simctl boot 'iPhone 16' 2>/dev/null || true
open -a Simulator
xcrun simctl install 'iPhone 16' \
  ~/Library/Developer/Xcode/DerivedData/TesseraRiss-*/Build/Products/Debug-iphonesimulator/TesseraRiss.app
xcrun simctl launch 'iPhone 16' de.maindtec.TesseraRiss
```

Replace `iPhone 16` with whatever device you have installed (`xcrun simctl list devices`).

---

## 📋 Known gaps

- All three audio files are silent. Music + SFX wiring is correct; you'll hear them as soon as you replace the WAV bytes.
- No unit / UI tests yet — the PLAN.md test plan (`BoardTests`, `ScoringTests`, `RandomizerTests`, `TetrominoTests`, smoke tests) is unbuilt.
- No SwiftUI previews (kept out of scope per the build instructions).
- Bundle ID is `de.maindtec.TesseraRiss` as a placeholder using the maintainer's email domain. Change `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml` and re-run `xcodegen generate` if you want a different one.
- Rotation uses fixed 4-state tables without SRS wall-kicks (PLAN.md notes the basic-rotation-with-collision-check approach is intentional and reads more "OG").
- Real-device verification has not been run from this checkout (only simulator). Haptics, physical-key behavior, and audio session ducking interactions should be confirmed on a real iPhone before TestFlight.
