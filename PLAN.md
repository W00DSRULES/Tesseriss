# Plan: OG-feel falling-blocks iOS game (working title: TetRiss)

## Context

You want a minimalist, comforting, OG-style Tetris-like game for iOS, free, no ads, no IAP — basically scratching the itch of "where did the simple, distraction-free version go." Constraints established in conversation:

- **Original branding** (not "Tetris", custom palette/look) — sidesteps The Tetris Company's notoriously aggressive trademark enforcement on the App Store.
- **Royalty-free *Korobeiniki* arrangement** — the 1861 folk composition is public domain; a CC-licensed recording avoids any licensing risk.
- **You're new to iOS**, so the plan is biased toward the simplest stack that still produces a polished result.
- **OG scoring + levels replicated** (NES Tetris rules): level rises every 10 lines, gravity speeds up per level, and clearing 4 rows at once ("Tetris") triggers a small celebratory visual + sound moment with a brief pause.

Feasibility is high. With original branding the App Store path is unblocked. Realistic build time as a solo learner: **3–5 weeks** to ship to App Store.

---

## Approach

### Tech stack
- **Language**: Swift 5+
- **UI**: **SwiftUI** end-to-end (no SpriteKit needed — the playfield is a 10×20 grid of colored rectangles; SwiftUI handles this fine and is much friendlier for a first iOS project)
- **Audio**: `AVAudioPlayer` (looping background track)
- **Haptics**: `UIImpactFeedbackGenerator` (`.light` for piece move, `.medium` for piece lock, `.heavy` or `UINotificationFeedbackGenerator.success` for line clears)
- **Persistence**: `UserDefaults` for highscore (single integer — no SwiftData/Core Data needed)
- **Xcode**: latest, targeting iOS 17+ (reduces device-fragmentation work)

### Game architecture (lightweight MVVM)
- `Tetromino` — shape matrix, rotation state, color, position
- `Board` — 10×20 grid, collision check, line detection/clearing
- `GameEngine: ObservableObject` — game loop (`Timer.publish` driven by `gravityInterval(level)`), holds `Board`, current/next piece, **score, level, linesCleared**, game-over flag, and a transient `clearAnimation` state used to pause gravity during clear animations
- `GameView` — SwiftUI view binding to `GameEngine`, shows playfield + next-piece preview + **score + level + lines**
- `ControlsView` — big touch buttons (see layout below)
- `MenuView` — start, highscore display, settings (music on/off, haptics on/off)
- `AudioController` — singleton wrapping `AVAudioPlayer`; plays a separate "tetris.wav" SFX over the music loop

### Scoring & levels (NES Tetris rules, replicated)
Per line-clear (where `level` starts at 0):
- Single: `40  × (level + 1)`
- Double: `100 × (level + 1)`
- Triple: `300 × (level + 1)`
- **Tetris (4-line)**: `1200 × (level + 1)`

Level progression: starts at 0, **+1 every 10 lines cleared**. Gravity (cells/sec drop) follows a simplified NES-style curve — table mapping level → tick interval, capped so it stays playable (e.g. level 20+ stays at the fastest practical speed).

### Line-clear feedback (Tetris celebration)
When `linesCleared == 4` in a single lock:
- **Pause gravity** for ~500ms (set `clearAnimation = .tetris` on the engine; game loop checks this flag and skips ticks)
- **Visual**: the four cleared rows flash white→palette color twice, then a brief subtle screen pulse/scale (1.0 → 1.02 → 1.0) — no shake, no particles, stays minimalist
- **Sound**: short distinct "tetris.wav" chime layered on top of the music
- **Haptic**: `UINotificationFeedbackGenerator.success`

For 1–3 line clears: shorter ~200ms pause, single row flash, soft haptic, no special chime. Keeps the Tetris moment feeling earned.

### Control layout (big buttons)
Proposed bottom-of-screen layout, thumbs-friendly on iPhone:
```
   [   ROTATE   ]
[ ◀ ] [ ▼ ] [ ▶ ]
   [   DROP    ]
```
- ROTATE = 90° clockwise (single rotation direction keeps it simple/OG)
- ▼ = soft drop (hold)
- DROP = hard drop (instant)
- All buttons ≥ 64pt tall, generous tap targets, slight haptic on press

### Visual style (minimalist + comforting)
- **Palette**: warm muted earth tones or soft pastels — NOT the high-contrast neon of modern Tetris clones. Suggested direction: cream background, 7 desaturated piece colors (dusty rose, sage, ochre, slate blue, terracotta, lavender, sand). Pick a final palette during week 1.
- **Pieces**: solid blocks with a single-pixel inner border, no gradients, no glow, no particles
- **Animations**: minimal — pieces snap to grid; line clear is a quick fade or single-frame flash (no explosions, no shake)
- **Typography**: one system font, large enough to read at arm's length

### Audio
- One looping track: a royalty-free *Korobeiniki* arrangement from Pixabay or FreeMusicArchive (verify license is CC0 or CC-BY before shipping; if CC-BY, credit in About screen)
- SFX (subtle, layered over music): piece lock click, single-line clear blip, **distinct "tetris" chime for 4-line clears**
- Toggle in settings for users who prefer silence (music + SFX togglable separately)

---

## Files to create (Xcode project structure)

```
TetRissApp/  (working title)
├── TetRissApp.swift              // @main entry
├── Models/
│   ├── Tetromino.swift
│   └── Board.swift
├── Engine/
│   └── GameEngine.swift
├── Views/
│   ├── MenuView.swift
│   ├── GameView.swift
│   ├── ControlsView.swift
│   └── CellView.swift
├── Services/
│   ├── AudioController.swift
│   └── HapticController.swift
├── Resources/
│   ├── Assets.xcassets           // palette colors, app icon
│   ├── korobeiniki.mp3           // looping background music
│   ├── line_clear.wav            // 1–3 line subtle blip
│   └── tetris.wav                // 4-line celebratory chime
└── Info.plist
```

No existing codebase to reuse — this is greenfield. Standard SRS (Super Rotation System) reference: [tetris.fandom.com/wiki/SRS](https://tetris.fandom.com/wiki/SRS). Use the standard 7-bag randomizer (each batch of 7 pieces contains one of each tetromino, shuffled) — gives the OG feel without long droughts of the same piece.

---

## Timeline (solo, learning as you go)

| Week | Goal | Verify |
|------|------|--------|
| 1 | Xcode + Apple Developer account ($99) setup. SwiftUI tutorial. Static playfield renders. | Run on simulator: see empty 10×20 grid |
| 2 | Tetromino spawn, gravity, rotation, collision, line clear, **NES scoring, level progression, gravity curve**, game-over | Play on simulator: score & level increment correctly, gravity speeds up at line 10/20/… |
| 3 | Controls + haptics + audio + **Tetris (4-line) celebration animation & chime** + highscore persistence | Play on real device, score a Tetris, feel the pause + flash + chime + success haptic |
| 4 | Palette polish, app icon, menu screen, settings, screenshots for App Store | TestFlight build runs cleanly |
| 5 | App Store submission, privacy policy page, review iteration | App approved & live |

---

## App Store submission checklist

- [ ] Apple Developer Program enrolled ($99/yr)
- [ ] App icon (1024×1024 + all required sizes)
- [ ] Screenshots: 6.5" iPhone + 5.5" iPhone minimum
- [ ] App description (avoid the word "Tetris"; describe as "falling blocks puzzle")
- [ ] **Privacy policy URL** (required even if you collect zero data — host a one-page "this app collects no data" on GitHub Pages)
- [ ] App Privacy questionnaire in App Store Connect: select "Data Not Collected"
- [ ] Music attribution in About screen (if CC-BY)
- [ ] Test on a real device (haptics don't work in simulator)

---

## Verification

End-to-end checks before each milestone:
1. **Mechanics correct**: pieces rotate via standard SRS, lock on contact, lines clear when filled.
2. **Scoring correct**: at level 0, single = 40, double = 100, triple = 300, **Tetris = 1200**. At level 1, all values double-plus (×2). Verify by clearing each type on simulator and inspecting the score readout.
3. **Level progression**: after every 10 lines cleared, level increments and gravity tick interval shortens — visible as faster falling pieces.
4. **Tetris celebration**: clearing 4 rows triggers ~500ms pause, the four rows flash, the chime plays, success haptic fires (on real device). 1–3 line clears get the subtler ~200ms pause + soft haptic.
5. **Game over**: when a new piece can't spawn, game ends and highscore updates if beaten.
6. **Haptics fire**: on real device — soft on move, firmer on lock, success haptic on Tetris.
7. **Audio**: music loops seamlessly; line-clear and tetris SFX layer cleanly over music; settings toggles silence them independently.
8. **Highscore persists**: kill the app, relaunch — highscore still shown.
9. **App Store readiness**: TestFlight build installs and runs on a real iPhone, no console errors.

---

## Open questions for later (not blocking)

- Final app name (working title: **TetRiss** — confirm App Store availability and check it reads as sufficiently distinct from "Tetris" for the App Store legal review; alternates: Cascade, Tessera, Stack)
- Exact palette — pick during week 1 after seeing options on-screen
- One or two rotation directions (current plan: one — simpler and OG-feeling)
- Soft-cap for gravity at high levels (e.g. clamp at level 19 like NES, or let it keep speeding up?)
- Sourcing the *tetris.wav* chime — pick something warm/chiptune-ish, not a harsh arcade buzz, to fit the comforting tone
