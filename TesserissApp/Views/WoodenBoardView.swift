import SwiftUI

/// Wooden-board surface used as the playfield backdrop in the Hokusai theme.
/// Procedural — a soft wood-tone base with subtle plank shading, sparse grain
/// lines, and a couple of knots. Drawn entirely with SwiftUI Canvas.
struct WoodenBoardView: View {
    let appearance: AppearanceMode

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                drawBase(ctx: &ctx, size: size)
                drawColorBands(ctx: &ctx, size: size)
                drawGrainLines(ctx: &ctx, size: size)
                drawEndGrainTicks(ctx: &ctx, size: size)
                if size.width > 120 && size.height > 120 {
                    drawKnots(ctx: &ctx, size: size)
                }
                drawEdgeShadow(ctx: &ctx, size: size)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var isDay: Bool { appearance == .day }

    // MARK: palette — neutral brown wood, not too orange.

    private var woodLight: Color {
        isDay ? Color(red: 0.741, green: 0.604, blue: 0.443)
              : Color(red: 0.196, green: 0.122, blue: 0.075)
    }
    private var woodMid: Color {
        isDay ? Color(red: 0.620, green: 0.475, blue: 0.318)
              : Color(red: 0.137, green: 0.082, blue: 0.047)
    }
    private var woodDark: Color {
        isDay ? Color(red: 0.494, green: 0.353, blue: 0.212)
              : Color(red: 0.090, green: 0.051, blue: 0.027)
    }
    private var grainDark: Color {
        isDay ? Color(red: 0.290, green: 0.180, blue: 0.078)
              : Color(red: 0.039, green: 0.020, blue: 0.012)
    }
    private var grainHighlight: Color {
        isDay ? Color(red: 0.831, green: 0.706, blue: 0.541)
              : Color(red: 0.275, green: 0.184, blue: 0.118)
    }
    private var knotColor: Color {
        isDay ? Color(red: 0.224, green: 0.122, blue: 0.047)
              : Color(red: 0.020, green: 0.012, blue: 0.008)
    }

    // MARK: drawing

    /// Vertical gradient — narrow tonal range so the surface reads as one flat plank,
    /// not a sharply-lit panel.
    private func drawBase(ctx: inout GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        let gradient = Gradient(stops: [
            .init(color: woodLight, location: 0.0),
            .init(color: woodMid,   location: 0.5),
            .init(color: woodDark,  location: 1.0),
        ])
        ctx.fill(
            Path(rect),
            with: .linearGradient(gradient,
                                  startPoint: CGPoint(x: size.width * 0.5, y: 0),
                                  endPoint: CGPoint(x: size.width * 0.5, y: size.height))
        )
    }

    /// A handful of broad, soft vertical color bands — subtle plank tone variation
    /// without looking striped.
    private func drawColorBands(ctx: inout GraphicsContext, size: CGSize) {
        var rng = SeededRNG(seed: 4242)
        let bandCount = max(2, min(5, Int(size.width / 60)))
        for _ in 0..<bandCount {
            let centerX = CGFloat(rng.nextUnit()) * size.width
            // wide soft bands rather than thin stripes
            let width = CGFloat(rng.nextUnit() * 0.4 + 0.4) * size.width * 0.55
            let shift = CGFloat(rng.nextUnit() - 0.5) * 0.06
            let color: Color = shift < 0 ? grainHighlight.opacity(-shift * 2.0)
                                         : grainDark.opacity(shift * 2.0)
            let rect = CGRect(x: centerX - width / 2, y: 0, width: width, height: size.height)
            let gradient = Gradient(stops: [
                .init(color: color.opacity(0.0), location: 0.0),
                .init(color: color,              location: 0.5),
                .init(color: color.opacity(0.0), location: 1.0),
            ])
            ctx.fill(
                Path(rect),
                with: .linearGradient(gradient,
                                      startPoint: CGPoint(x: rect.minX, y: rect.midY),
                                      endPoint: CGPoint(x: rect.maxX, y: rect.midY))
            )
        }
    }

    /// Thin grain lines running roughly vertically, with subtle side-to-side wander.
    /// Sparse — fewer lines = more natural plank.
    private func drawGrainLines(ctx: inout GraphicsContext, size: CGSize) {
        var rng = SeededRNG(seed: 17171)
        // Cap line density so we don't get a haystack on big surfaces.
        let lineCount = min(14, max(5, Int(size.width / 22)))
        for _ in 0..<lineCount {
            let startX = CGFloat(rng.nextUnit()) * size.width
            let wander = CGFloat(rng.nextUnit() - 0.5) * size.width * 0.05
            let darken = CGFloat(rng.nextUnit())
            let color: Color = (rng.nextUnit() < 0.7)
                ? grainDark.opacity(0.05 + darken * 0.10)
                : grainHighlight.opacity(0.04 + darken * 0.08)
            let width: CGFloat = 0.5 + CGFloat(rng.nextUnit()) * 0.9

            var path = Path()
            let segments = 7
            let phase = Double(rng.nextUnit()) * 6
            for i in 0...segments {
                let t = CGFloat(i) / CGFloat(segments)
                let yPos = t * size.height
                let drift = CGFloat(sin(Double(t) * .pi * 2 + phase))
                    * wander
                let x = startX + drift
                if i == 0 { path.move(to: CGPoint(x: x, y: yPos)) }
                else      { path.addLine(to: CGPoint(x: x, y: yPos)) }
            }
            ctx.stroke(path, with: .color(color),
                       style: StrokeStyle(lineWidth: width, lineCap: .round))
        }
    }

    /// Very short tick marks scattered sparsely — flecks/pores in the wood.
    private func drawEndGrainTicks(ctx: inout GraphicsContext, size: CGSize) {
        var rng = SeededRNG(seed: 28291)
        let tickCount = max(4, Int(size.width * size.height / 4500))
        for _ in 0..<tickCount {
            let x = CGFloat(rng.nextUnit()) * size.width
            let y = CGFloat(rng.nextUnit()) * size.height
            let length: CGFloat = 1.0 + CGFloat(rng.nextUnit()) * 2.5
            var tick = Path()
            tick.move(to: CGPoint(x: x, y: y))
            tick.addLine(to: CGPoint(x: x, y: y + length))
            ctx.stroke(tick,
                       with: .color(grainDark.opacity(0.06 + CGFloat(rng.nextUnit()) * 0.08)),
                       style: StrokeStyle(lineWidth: 0.5, lineCap: .round))
        }
    }

    /// 1–2 sparse knots — gives the board character without being busy.
    private func drawKnots(ctx: inout GraphicsContext, size: CGSize) {
        var rng = SeededRNG(seed: 9001)
        let area = size.width * size.height
        let knotCount = max(1, min(2, Int(area / 90000)))
        for _ in 0..<knotCount {
            let cx = size.width  * CGFloat(0.15 + rng.nextUnit() * 0.70)
            let cy = size.height * CGFloat(0.15 + rng.nextUnit() * 0.70)
            let outer: CGFloat = 5 + CGFloat(rng.nextUnit()) * 6
            let inner: CGFloat = outer * 0.55

            // Halo: a slightly darker stain around the knot where the grain bends.
            let haloRect = CGRect(x: cx - outer * 1.7, y: cy - outer * 1.1,
                                  width: outer * 3.4, height: outer * 2.2)
            let haloGrad = Gradient(stops: [
                .init(color: grainDark.opacity(0.18), location: 0.0),
                .init(color: grainDark.opacity(0.0),  location: 1.0),
            ])
            ctx.fill(Path(ellipseIn: haloRect),
                     with: .radialGradient(haloGrad,
                                           center: CGPoint(x: cx, y: cy),
                                           startRadius: 0, endRadius: outer * 1.7))

            // The knot itself: dark center fading out.
            let knotRect = CGRect(x: cx - outer, y: cy - outer * 0.75,
                                  width: outer * 2, height: outer * 1.5)
            let gradient = Gradient(stops: [
                .init(color: knotColor,                 location: 0.0),
                .init(color: knotColor.opacity(0.55),   location: 0.55),
                .init(color: knotColor.opacity(0.0),    location: 1.0),
            ])
            ctx.fill(Path(ellipseIn: knotRect),
                     with: .radialGradient(gradient,
                                           center: CGPoint(x: cx, y: cy),
                                           startRadius: 0, endRadius: outer))

            // Inner ring of denser wood.
            let innerRing = Path(ellipseIn: CGRect(x: cx - inner, y: cy - inner * 0.8,
                                                   width: inner * 2, height: inner * 1.6))
            ctx.stroke(innerRing, with: .color(grainDark.opacity(0.45)),
                       style: StrokeStyle(lineWidth: 0.7))
        }
    }

    /// Subtle edge shadow + soft top-left highlight so the board reads as inset.
    private func drawEdgeShadow(ctx: inout GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        let gradient = Gradient(stops: [
            .init(color: Color.black.opacity(0.22), location: 0.0),
            .init(color: Color.black.opacity(0.0),  location: 0.10),
            .init(color: Color.black.opacity(0.0),  location: 0.90),
            .init(color: Color.black.opacity(0.16), location: 1.0),
        ])
        ctx.fill(
            Path(rect),
            with: .linearGradient(gradient,
                                  startPoint: CGPoint(x: 0, y: rect.minY),
                                  endPoint: CGPoint(x: 0, y: rect.maxY))
        )
        // soft inner highlight running diagonally
        let hl = Gradient(stops: [
            .init(color: Color.white.opacity(0.06), location: 0.0),
            .init(color: Color.white.opacity(0.0),  location: 0.55),
        ])
        ctx.fill(
            Path(rect),
            with: .linearGradient(hl,
                                  startPoint: CGPoint(x: rect.minX, y: rect.minY),
                                  endPoint: CGPoint(x: rect.maxX, y: rect.maxY))
        )
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
