import SwiftUI

/// White-dominant splash overlay drawn over the playfield during line clears.
/// Centered on the cleared rows: bright foam burst, radiating spray, foam streaks,
/// and curling foam claws — scaled by row count.
struct WaveSplashView: View {
    let appearance: AppearanceMode
    let rows: [Int]
    let cellSize: CGFloat
    let isFourLine: Bool

    @State private var startTime: Date = Date()
    @State private var lastKey: String = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 90.0, paused: false)) { timeline in
            // Duration matches engine clear pause + a hair so the tail is just cut off.
            let duration: TimeInterval = isFourLine ? 0.55 : 0.32
            let elapsed = timeline.date.timeIntervalSince(startTime)
            let progress = max(0, min(1, elapsed / duration))
            Canvas { ctx, size in
                guard !rows.isEmpty, cellSize > 0 else { return }
                draw(ctx: &ctx, size: size, progress: progress)
            }
        }
        .onAppear { restart() }
        .onChange(of: key) { _, _ in restart() }
        .allowsHitTesting(false)
    }

    private var key: String {
        rows.sorted().map(String.init).joined(separator: ",") + (isFourLine ? "!" : "")
    }

    private func restart() {
        guard !rows.isEmpty, key != lastKey else { return }
        lastKey = key
        startTime = Date()
    }

    // MARK: drawing

    private var foam: Color { KanagawaTheme.foamColor(appearance: appearance) }
    private var waveDeep: Color { KanagawaTheme.waveDeepColor(appearance: appearance) }

    private func draw(ctx: inout GraphicsContext, size: CGSize, progress: CGFloat) {
        let rowCount = rows.count
        let minRow = rows.min() ?? 0
        let maxRow = rows.max() ?? 0
        let bandTop = CGFloat(minRow) * cellSize
        let bandBottom = CGFloat(maxRow + 1) * cellSize
        let bandHeight = bandBottom - bandTop
        let bandCenterY = (bandTop + bandBottom) / 2

        let alpha = envelope(progress: progress)
        guard alpha > 0.01 else { return }

        // 1. Thin blue undertone wash — provides depth without dominating.
        drawBlueUndertone(ctx: &ctx, size: size,
                          bandTop: bandTop, bandBottom: bandBottom,
                          alpha: alpha)

        // 2. Bright white wash filling the cleared band.
        drawFoamWash(ctx: &ctx, size: size,
                     bandTop: bandTop, bandBottom: bandBottom,
                     alpha: alpha, rowCount: rowCount)

        // 3. Big radial impact bursts along the cleared band.
        drawImpactBursts(ctx: &ctx, size: size,
                         bandCenterY: bandCenterY, bandHeight: bandHeight,
                         progress: progress, alpha: alpha, rowCount: rowCount)

        // 4. Radiating foam streaks (motion lines).
        drawFoamStreaks(ctx: &ctx, size: size,
                        bandCenterY: bandCenterY,
                        progress: progress, alpha: alpha, rowCount: rowCount)

        // 5. Curling foam claws at the splash edges.
        drawFoamClaws(ctx: &ctx, size: size,
                      bandCenterY: bandCenterY, bandHeight: bandHeight,
                      progress: progress, alpha: alpha, rowCount: rowCount)

        // 6. Exploding spray droplets.
        drawSpray(ctx: &ctx, size: size,
                  bandCenterY: bandCenterY, bandHeight: bandHeight,
                  progress: progress, alpha: alpha, rowCount: rowCount)
    }

    private func drawBlueUndertone(ctx: inout GraphicsContext, size: CGSize,
                                   bandTop: CGFloat, bandBottom: CGFloat,
                                   alpha: CGFloat) {
        let rect = CGRect(x: 0, y: bandTop, width: size.width, height: bandBottom - bandTop)
        ctx.fill(Path(rect), with: .color(waveDeep.opacity(0.30 * alpha)))
    }

    /// Bright white-foam wash covering the cleared band with soft edges.
    private func drawFoamWash(ctx: inout GraphicsContext, size: CGSize,
                              bandTop: CGFloat, bandBottom: CGFloat,
                              alpha: CGFloat, rowCount: Int) {
        // Pad the wash beyond the band so the gradient peaks across more vertical room,
        // making single-row clears feel as splashy as multi-row ones.
        let basePad: CGFloat = max(cellSize * 0.8, 12)
        let pad: CGFloat = basePad + CGFloat(rowCount) * 5
        let top = bandTop - pad
        let bottom = bandBottom + pad
        let rect = CGRect(x: 0, y: top, width: size.width, height: bottom - top)
        let intensity: CGFloat
        switch rowCount {
        case 1:  intensity = 0.92
        case 2:  intensity = 0.95
        case 3:  intensity = 0.97
        default: intensity = 1.00
        }
        let gradient = Gradient(stops: [
            .init(color: foam.opacity(0.0),                       location: 0.0),
            .init(color: foam.opacity(intensity * alpha),         location: 0.42),
            .init(color: foam.opacity(intensity * alpha * 1.05),  location: 0.58),
            .init(color: foam.opacity(0.0),                       location: 1.0),
        ])
        ctx.fill(
            Path(rect),
            with: .linearGradient(gradient,
                                  startPoint: CGPoint(x: 0, y: top),
                                  endPoint: CGPoint(x: 0, y: bottom))
        )
    }

    /// Bright radial foam bursts — like circles of impact spray.
    private func drawImpactBursts(ctx: inout GraphicsContext, size: CGSize,
                                  bandCenterY: CGFloat, bandHeight: CGFloat,
                                  progress: CGFloat, alpha: CGFloat, rowCount: Int) {
        let burstCount: Int
        switch rowCount {
        case 1:  burstCount = 3
        case 2:  burstCount = 4
        case 3:  burstCount = 5
        default: burstCount = 7
        }
        let baseRadius = max(cellSize * 2.2, size.width * 0.22)
        let growth: CGFloat = 1.0 + 0.9 * progress
        for i in 0..<burstCount {
            let frac = (CGFloat(i) + 0.5) / CGFloat(burstCount)
            // Stagger horizontally + give a tiny vertical wobble.
            let cx = size.width * frac
            let cy = bandCenterY + CGFloat(sin(Double(i) * 1.7)) * bandHeight * 0.18
            let r = baseRadius * growth * (1.0 + 0.3 * CGFloat(sin(Double(i) * 2.1)))
            let rect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
            let burstAlpha = alpha * (1.0 - 0.4 * progress)
            let gradient = Gradient(stops: [
                .init(color: foam.opacity(0.95 * burstAlpha), location: 0.0),
                .init(color: foam.opacity(0.55 * burstAlpha), location: 0.45),
                .init(color: foam.opacity(0.0),               location: 1.0),
            ])
            ctx.fill(
                Path(ellipseIn: rect),
                with: .radialGradient(gradient,
                                      center: CGPoint(x: cx, y: cy),
                                      startRadius: 0, endRadius: r)
            )
        }
    }

    /// Diagonal foam streaks radiating from the band — motion lines for splash energy.
    private func drawFoamStreaks(ctx: inout GraphicsContext, size: CGSize,
                                 bandCenterY: CGFloat,
                                 progress: CGFloat, alpha: CGFloat, rowCount: Int) {
        let streakCount: Int
        switch rowCount {
        case 1:  streakCount = 18
        case 2:  streakCount = 24
        case 3:  streakCount = 30
        default: streakCount = 44
        }
        var rng = SeededRNG(seed: UInt64(rowCount) &* 31337 &+ (isFourLine ? 1 : 7))
        for _ in 0..<streakCount {
            let startX = CGFloat(rng.nextUnit()) * size.width
            let startY = bandCenterY + CGFloat(rng.nextUnit() - 0.5) * cellSize * 1.2
            // Mostly upward angles; some downward for splashy spread.
            let upwardBias: Double = rng.nextUnit() < 0.7 ? -1 : 1
            let angle = (rng.nextUnit() - 0.5) * 1.3 + (upwardBias < 0 ? -.pi / 2 : .pi / 2)
            let length = CGFloat(rng.nextUnit() * 0.6 + 0.4) * size.width * 0.28
            let extend = length * (0.4 + 0.6 * progress)
            let endX = startX + cos(angle) * extend
            let endY = startY + sin(angle) * extend
            let width = CGFloat(rng.nextUnit() * 1.6 + 0.6) * (isFourLine ? 1.6 : 1.0)
            var streak = Path()
            streak.move(to: CGPoint(x: startX, y: startY))
            streak.addLine(to: CGPoint(x: endX, y: endY))
            let streakAlpha = alpha * (1.0 - max(0, CGFloat(progress - 0.6) / 0.4))
            ctx.stroke(streak,
                       with: .color(foam.opacity(0.85 * streakAlpha)),
                       style: StrokeStyle(lineWidth: width, lineCap: .round))
        }
    }

    /// Curling foam fingers — the iconic Hokusai claw shape, multiplied for splash effect.
    private func drawFoamClaws(ctx: inout GraphicsContext, size: CGSize,
                               bandCenterY: CGFloat, bandHeight: CGFloat,
                               progress: CGFloat, alpha: CGFloat, rowCount: Int) {
        let clawCount: Int
        switch rowCount {
        case 1:  clawCount = 6
        case 2:  clawCount = 8
        case 3:  clawCount = 12
        default: clawCount = 18
        }
        let lift = min(1, progress * 2.3)
        for i in 0..<clawCount {
            let frac = (CGFloat(i) + 0.5) / CGFloat(clawCount)
            let baseX = frac * size.width
            let yJitter = CGFloat(sin(Double(i) * 1.9)) * bandHeight * 0.3
            let baseY = bandCenterY + yJitter
            let direction: CGFloat = (i % 2 == 0) ? 1 : -1
            let length = max(bandHeight, cellSize * 2.0) * (1.4 + 0.5 * CGFloat(sin(Double(i) * 0.9)))
            let tipX = baseX + direction * length * 0.35
            let tipY = baseY - length * lift
            let ctrl1 = CGPoint(x: baseX - direction * length * 0.12,
                                y: baseY - length * 0.40 * lift)
            let ctrl2 = CGPoint(x: tipX + direction * length * 0.22,
                                y: tipY + length * 0.18)
            var claw = Path()
            claw.move(to: CGPoint(x: baseX, y: baseY))
            claw.addCurve(to: CGPoint(x: tipX, y: tipY), control1: ctrl1, control2: ctrl2)
            ctx.stroke(claw,
                       with: .color(foam.opacity(0.95 * alpha)),
                       style: StrokeStyle(lineWidth: max(3, length * 0.07), lineCap: .round))
            // Round droplet at the tip of each claw.
            let r: CGFloat = max(3.5, length * 0.06)
            let tipDot = Path(ellipseIn: CGRect(x: tipX - r, y: tipY - r, width: r * 2, height: r * 2))
            ctx.fill(tipDot, with: .color(foam.opacity(alpha)))
        }
    }

    /// Many white spray droplets exploding outward — varied sizes, mostly upward.
    private func drawSpray(ctx: inout GraphicsContext, size: CGSize,
                           bandCenterY: CGFloat, bandHeight: CGFloat,
                           progress: CGFloat, alpha: CGFloat, rowCount: Int) {
        let count: Int
        switch rowCount {
        case 1:  count = 60
        case 2:  count = 85
        case 3:  count = 115
        default: count = 170
        }
        var rng = SeededRNG(seed: UInt64(rowCount) &* 9176 &+ (isFourLine ? 1 : 11))
        for _ in 0..<count {
            let startX = CGFloat(rng.nextUnit()) * size.width
            let startY = bandCenterY + CGFloat(rng.nextUnit() - 0.5) * bandHeight
            let lateralRange: CGFloat = isFourLine ? 0.75 : 0.40
            let lateral = CGFloat(rng.nextUnit() - 0.5) * size.width * lateralRange
            let lift = CGFloat(rng.nextUnit() * 0.7 + 0.5) * size.height * (isFourLine ? 0.85 : 0.55)
            let t = progress
            let gravity: CGFloat = 1.05
            let x = startX + lateral * t
            let y = startY - lift * t + (lift * gravity) * t * t
            // Varied droplet sizes — a mix of small spray and chunkier drops.
            let sizeRoll = rng.nextUnit()
            let baseR: CGFloat
            if sizeRoll < 0.65 {
                baseR = isFourLine ? 1.8 : 1.2
            } else if sizeRoll < 0.92 {
                baseR = isFourLine ? 3.8 : 2.6
            } else {
                baseR = isFourLine ? 6.5 : 4.4
            }
            let radius = baseR + CGFloat(rng.nextUnit()) * baseR * 0.6
            let dotAlpha = alpha * (1.0 - CGFloat(max(0, (t - 0.7) / 0.3)))
            let dot = Path(ellipseIn: CGRect(x: x - radius, y: y - radius,
                                             width: radius * 2, height: radius * 2))
            ctx.fill(dot, with: .color(foam.opacity(dotAlpha)))
        }
    }

    /// Fast rise, hold near 1.0, quick fade-out at the tail.
    private func envelope(progress: CGFloat) -> CGFloat {
        if reduceMotion { return progress < 1 ? 0.9 : 0 }
        if progress < 0.05 { return progress / 0.05 }
        if progress > 0.85 { return max(0, (1.0 - progress) / 0.15) }
        return 1.0
    }
}

private struct SeededRNG {
    var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
    mutating func nextUnit() -> Double {
        Double(next() & 0xFFFFFF) / Double(0xFFFFFF)
    }
}
