import SwiftUI

/// Static ukiyo-e backdrop modelled on Hokusai's "The Great Wave off Kanagawa".
/// Composition (portrait-adapted): dominant wave on the LEFT with curling foam
/// claws reaching RIGHTWARD across the upper sky, small Mt Fuji peering through
/// the gap, smaller secondary wave at the bottom-right.
struct KanagawaBackgroundView: View {
    let appearance: AppearanceMode

    /// Asset name in Assets.xcassets. When present the image is used as the backdrop;
    /// otherwise the procedural canvas below renders instead.
    private static let backdropAssetName = "KanagawaBackdrop"

    var body: some View {
        ZStack {
            if UIImage(named: Self.backdropAssetName) != nil {
                Image(Self.backdropAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                proceduralBackdrop
            }
        }
        .ignoresSafeArea()
    }

    private var proceduralBackdrop: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                drawPaper(ctx: &ctx, size: size)
                drawSkyHaze(ctx: &ctx, size: size)
                drawDistantClouds(ctx: &ctx, size: size)
                drawFuji(ctx: &ctx, size: size)
                drawSecondaryWave(ctx: &ctx, size: size)
                drawBigWaveBody(ctx: &ctx, size: size)
                drawBigWaveInteriorFoam(ctx: &ctx, size: size)
                drawBigWaveCrestRidge(ctx: &ctx, size: size)
                drawBigWaveClaws(ctx: &ctx, size: size)
                drawSpray(ctx: &ctx, size: size)
                drawPaperGrain(ctx: &ctx, size: size)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var isDay: Bool { appearance == .day }

    // MARK: palette

    private var paperTop: Color {
        isDay ? Color(red: 0.957, green: 0.929, blue: 0.851)
              : Color(red: 0.067, green: 0.094, blue: 0.184)
    }
    private var paperMid: Color {
        isDay ? Color(red: 0.918, green: 0.882, blue: 0.788)
              : Color(red: 0.039, green: 0.063, blue: 0.129)
    }
    private var paperBottom: Color {
        isDay ? Color(red: 0.847, green: 0.792, blue: 0.690)
              : Color(red: 0.020, green: 0.039, blue: 0.086)
    }
    private var hazeColor: Color {
        isDay ? Color(red: 0.690, green: 0.706, blue: 0.624).opacity(0.55)
              : Color(red: 0.169, green: 0.243, blue: 0.380).opacity(0.55)
    }
    private var cloudColor: Color {
        isDay ? Color(red: 0.973, green: 0.949, blue: 0.890).opacity(0.70)
              : Color(red: 0.412, green: 0.498, blue: 0.643).opacity(0.30)
    }
    private var fujiBody: Color {
        isDay ? Color(red: 0.227, green: 0.243, blue: 0.302)
              : Color(red: 0.129, green: 0.157, blue: 0.227)
    }
    private var fujiShadow: Color {
        isDay ? Color(red: 0.133, green: 0.145, blue: 0.196)
              : Color(red: 0.078, green: 0.098, blue: 0.157)
    }
    private var fujiSnow: Color {
        isDay ? Color(red: 0.969, green: 0.957, blue: 0.918)
              : Color(red: 0.835, green: 0.875, blue: 0.937)
    }
    private var waveTop: Color {
        isDay ? Color(red: 0.224, green: 0.408, blue: 0.612)
              : Color(red: 0.180, green: 0.341, blue: 0.541)
    }
    private var waveBody: Color {
        isDay ? Color(red: 0.110, green: 0.243, blue: 0.439)
              : Color(red: 0.094, green: 0.196, blue: 0.388)
    }
    private var waveDeep: Color {
        isDay ? Color(red: 0.027, green: 0.094, blue: 0.220)
              : Color(red: 0.027, green: 0.067, blue: 0.149)
    }
    private var ink: Color {
        isDay ? Color(red: 0.024, green: 0.063, blue: 0.137)
              : Color(red: 0.012, green: 0.027, blue: 0.067)
    }
    private var foam: Color {
        isDay ? Color(red: 0.984, green: 0.965, blue: 0.914)
              : Color(red: 0.878, green: 0.910, blue: 0.957)
    }

    // MARK: drawing

    private func drawPaper(ctx: inout GraphicsContext, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        let gradient = Gradient(stops: [
            .init(color: paperTop,    location: 0.0),
            .init(color: paperMid,    location: 0.55),
            .init(color: paperBottom, location: 1.0),
        ])
        ctx.fill(
            Path(rect),
            with: .linearGradient(gradient,
                                  startPoint: CGPoint(x: size.width * 0.5, y: 0),
                                  endPoint: CGPoint(x: size.width * 0.5, y: size.height))
        )
    }

    private func drawSkyHaze(ctx: inout GraphicsContext, size: CGSize) {
        let bandTop = size.height * 0.0
        let bandBottom = size.height * 0.25
        let rect = CGRect(x: 0, y: bandTop, width: size.width, height: bandBottom - bandTop)
        let gradient = Gradient(stops: [
            .init(color: hazeColor,               location: 0.0),
            .init(color: hazeColor.opacity(0.0),  location: 1.0),
        ])
        ctx.fill(
            Path(rect),
            with: .linearGradient(gradient,
                                  startPoint: CGPoint(x: 0, y: bandTop),
                                  endPoint: CGPoint(x: 0, y: bandBottom))
        )
    }

    private func drawDistantClouds(ctx: inout GraphicsContext, size: CGSize) {
        // A few elongated clouds high in the sky (background).
        let clouds: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (0.20, 0.10, 0.30, 0.022),
            (0.68, 0.14, 0.28, 0.018),
            (0.45, 0.20, 0.22, 0.014),
        ]
        for (cx, cy, w, h) in clouds {
            let centerX = size.width * cx
            let centerY = size.height * cy
            let width = size.width * w
            let height = size.height * h
            let rect = CGRect(x: centerX - width / 2, y: centerY - height / 2,
                              width: width, height: height)
            ctx.fill(Path(roundedRect: rect, cornerRadius: height), with: .color(cloudColor))
        }
    }

    /// Mt Fuji — small, distant, in the upper-right area, peering through the wave gap.
    private func drawFuji(ctx: inout GraphicsContext, size: CGSize) {
        let baseY = size.height * 0.42
        let peakY = size.height * 0.24
        let centerX = size.width * 0.72
        let halfBase = size.width * 0.18
        let topHalf = size.width * 0.028

        var body = Path()
        body.move(to: CGPoint(x: centerX - halfBase, y: baseY))
        body.addCurve(
            to: CGPoint(x: centerX - topHalf, y: peakY + 2),
            control1: CGPoint(x: centerX - halfBase * 0.78, y: baseY - (baseY - peakY) * 0.30),
            control2: CGPoint(x: centerX - halfBase * 0.30, y: peakY + (baseY - peakY) * 0.18)
        )
        body.addQuadCurve(
            to: CGPoint(x: centerX + topHalf, y: peakY + 2),
            control: CGPoint(x: centerX, y: peakY - 4)
        )
        body.addCurve(
            to: CGPoint(x: centerX + halfBase, y: baseY),
            control1: CGPoint(x: centerX + halfBase * 0.30, y: peakY + (baseY - peakY) * 0.18),
            control2: CGPoint(x: centerX + halfBase * 0.78, y: baseY - (baseY - peakY) * 0.30)
        )
        body.closeSubpath()
        ctx.fill(body, with: .color(fujiBody))

        // Right-side shadow.
        var shadow = Path()
        shadow.move(to: CGPoint(x: centerX, y: peakY - 1))
        shadow.addLine(to: CGPoint(x: centerX + topHalf, y: peakY + 2))
        shadow.addCurve(
            to: CGPoint(x: centerX + halfBase, y: baseY),
            control1: CGPoint(x: centerX + halfBase * 0.30, y: peakY + (baseY - peakY) * 0.18),
            control2: CGPoint(x: centerX + halfBase * 0.78, y: baseY - (baseY - peakY) * 0.30)
        )
        shadow.addLine(to: CGPoint(x: centerX, y: baseY))
        shadow.closeSubpath()
        ctx.fill(shadow, with: .color(fujiShadow.opacity(0.6)))

        // Snowcap with ragged drips.
        let snowDepth = (baseY - peakY) * 0.42
        let snowBottom = peakY + snowDepth
        var snow = Path()
        snow.move(to: CGPoint(x: centerX - halfBase * 0.20, y: snowBottom + snowDepth * 0.05))
        snow.addQuadCurve(
            to: CGPoint(x: centerX - topHalf * 0.6, y: peakY + 4),
            control: CGPoint(x: centerX - halfBase * 0.10, y: snowBottom - snowDepth * 0.55)
        )
        snow.addQuadCurve(
            to: CGPoint(x: centerX + topHalf * 0.6, y: peakY + 4),
            control: CGPoint(x: centerX, y: peakY - 3)
        )
        snow.addQuadCurve(
            to: CGPoint(x: centerX + halfBase * 0.20, y: snowBottom + snowDepth * 0.05),
            control: CGPoint(x: centerX + halfBase * 0.10, y: snowBottom - snowDepth * 0.55)
        )
        let dripCount = 4
        for i in stride(from: dripCount - 1, through: 0, by: -1) {
            let frac = (CGFloat(i) + 0.5) / CGFloat(dripCount)
            let dripX = centerX - halfBase * 0.20 + (halfBase * 0.40) * frac
            let dripY = snowBottom + snowDepth * (0.05 + 0.18 * CGFloat(sin(Double(i) * 1.7)))
            snow.addLine(to: CGPoint(x: dripX, y: dripY))
            let valleyX = dripX - halfBase * 0.020
            let valleyY = snowBottom - snowDepth * (0.06 + 0.07 * CGFloat(cos(Double(i) * 1.3)))
            snow.addLine(to: CGPoint(x: valleyX, y: valleyY))
        }
        snow.closeSubpath()
        ctx.fill(snow, with: .color(fujiSnow))
    }

    /// Secondary smaller wave at the bottom-right — mirror of the big wave's drama.
    private func drawSecondaryWave(ctx: inout GraphicsContext, size: CGSize) {
        let baseY = size.height * 0.92
        let peakX = size.width * 0.85
        let peakY = size.height * 0.62

        var path = Path()
        path.move(to: CGPoint(x: size.width * 0.55, y: baseY))
        path.addCurve(
            to: CGPoint(x: peakX, y: peakY),
            control1: CGPoint(x: size.width * 0.62, y: baseY - size.height * 0.06),
            control2: CGPoint(x: size.width * 0.78, y: peakY + size.height * 0.04)
        )
        // Mini curl
        path.addQuadCurve(
            to: CGPoint(x: peakX + size.width * 0.04, y: peakY - size.height * 0.03),
            control: CGPoint(x: peakX + size.width * 0.015, y: peakY - size.height * 0.05)
        )
        path.addCurve(
            to: CGPoint(x: size.width, y: baseY - size.height * 0.02),
            control1: CGPoint(x: peakX + size.width * 0.10, y: peakY + size.height * 0.03),
            control2: CGPoint(x: size.width * 0.95, y: baseY - size.height * 0.05)
        )
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: size.width * 0.55, y: size.height))
        path.closeSubpath()

        let gradient = Gradient(stops: [
            .init(color: waveTop,   location: 0.0),
            .init(color: waveBody,  location: 0.5),
            .init(color: waveDeep,  location: 1.0),
        ])
        ctx.fill(
            path,
            with: .linearGradient(gradient,
                                  startPoint: CGPoint(x: 0, y: peakY - size.height * 0.04),
                                  endPoint: CGPoint(x: 0, y: size.height))
        )

        // Foam ridge along the crest of the small wave.
        var ridge = Path()
        ridge.move(to: CGPoint(x: size.width * 0.55 + 6, y: baseY - size.height * 0.012))
        ridge.addCurve(
            to: CGPoint(x: peakX, y: peakY + size.height * 0.012),
            control1: CGPoint(x: size.width * 0.62, y: baseY - size.height * 0.07),
            control2: CGPoint(x: size.width * 0.78, y: peakY + size.height * 0.05)
        )
        ridge.addQuadCurve(
            to: CGPoint(x: peakX + size.width * 0.035, y: peakY - size.height * 0.018),
            control: CGPoint(x: peakX + size.width * 0.012, y: peakY - size.height * 0.04)
        )
        ctx.stroke(ridge, with: .color(foam.opacity(0.92)),
                   style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))

        // Ink outline.
        var outline = Path()
        outline.move(to: CGPoint(x: size.width * 0.55, y: baseY))
        outline.addCurve(
            to: CGPoint(x: peakX, y: peakY),
            control1: CGPoint(x: size.width * 0.62, y: baseY - size.height * 0.06),
            control2: CGPoint(x: size.width * 0.78, y: peakY + size.height * 0.04)
        )
        outline.addQuadCurve(
            to: CGPoint(x: peakX + size.width * 0.04, y: peakY - size.height * 0.03),
            control: CGPoint(x: peakX + size.width * 0.015, y: peakY - size.height * 0.05)
        )
        outline.addCurve(
            to: CGPoint(x: size.width, y: baseY - size.height * 0.02),
            control1: CGPoint(x: peakX + size.width * 0.10, y: peakY + size.height * 0.03),
            control2: CGPoint(x: size.width * 0.95, y: baseY - size.height * 0.05)
        )
        ctx.stroke(outline, with: .color(ink.opacity(0.65)),
                   style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))

        // A couple of small claws on the secondary wave.
        for i in 0..<3 {
            let frac = (CGFloat(i) + 0.5) / 3.0
            let baseX = size.width * (0.72 + frac * 0.18)
            let bY = peakY + CGFloat(sin(Double(i) * 1.9)) * size.height * 0.012
            let length = size.height * 0.05
            let direction: CGFloat = i % 2 == 0 ? 1 : -1
            let tipX = baseX + direction * length * 0.35
            let tipY = bY - length
            let ctrl1 = CGPoint(x: baseX + direction * length * 0.05, y: bY - length * 0.35)
            let ctrl2 = CGPoint(x: tipX + direction * length * 0.20, y: tipY + length * 0.18)
            var claw = Path()
            claw.move(to: CGPoint(x: baseX, y: bY))
            claw.addCurve(to: CGPoint(x: tipX, y: tipY), control1: ctrl1, control2: ctrl2)
            ctx.stroke(claw, with: .color(foam.opacity(0.85)),
                       style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
            let r: CGFloat = 2.4
            ctx.fill(Path(ellipseIn: CGRect(x: tipX - r, y: tipY - r, width: r * 2, height: r * 2)),
                     with: .color(foam.opacity(0.95)))
        }
    }

    /// The dominant Hokusai wave — towering on the left, crest curling toward the right.
    private func drawBigWaveBody(ctx: inout GraphicsContext, size: CGSize) {
        let p = bigWavePath(size: size)
        let gradient = Gradient(stops: [
            .init(color: waveTop,  location: 0.0),
            .init(color: waveBody, location: 0.45),
            .init(color: waveDeep, location: 1.0),
        ])
        ctx.fill(
            p,
            with: .linearGradient(gradient,
                                  startPoint: CGPoint(x: 0, y: size.height * 0.10),
                                  endPoint: CGPoint(x: 0, y: size.height))
        )

        // Ink outline along the visible upper edge.
        var outline = Path()
        let pts = bigWaveTopEdgePoints(size: size)
        outline.move(to: pts[0].point)
        for seg in pts.dropFirst() {
            switch seg.kind {
            case .line:
                outline.addLine(to: seg.point)
            case .curve(let c1, let c2):
                outline.addCurve(to: seg.point, control1: c1, control2: c2)
            case .quad(let c):
                outline.addQuadCurve(to: seg.point, control: c)
            }
        }
        ctx.stroke(outline, with: .color(ink.opacity(0.78)),
                   style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
    }

    /// Lighter foam-tinged interior suggesting the hollow inside the curl.
    private func drawBigWaveInteriorFoam(ctx: inout GraphicsContext, size: CGSize) {
        // The "eye" of the wave — a lighter pocket just under the crest curl.
        let cx = size.width * 0.40
        let cy = size.height * 0.32
        let rx = size.width * 0.18
        let ry = size.height * 0.10
        var pocket = Path()
        pocket.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
        let gradient = Gradient(stops: [
            .init(color: foam.opacity(0.55), location: 0.0),
            .init(color: foam.opacity(0.20), location: 0.6),
            .init(color: foam.opacity(0.0),  location: 1.0),
        ])
        ctx.fill(pocket,
                 with: .radialGradient(gradient,
                                       center: CGPoint(x: cx, y: cy),
                                       startRadius: 0, endRadius: max(rx, ry)))

        // Inner curling foam line under the crest — suggests rolling water.
        var roll = Path()
        roll.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.42))
        roll.addCurve(
            to: CGPoint(x: size.width * 0.38, y: size.height * 0.28),
            control1: CGPoint(x: size.width * 0.24, y: size.height * 0.42),
            control2: CGPoint(x: size.width * 0.32, y: size.height * 0.32)
        )
        roll.addCurve(
            to: CGPoint(x: size.width * 0.52, y: size.height * 0.34),
            control1: CGPoint(x: size.width * 0.44, y: size.height * 0.26),
            control2: CGPoint(x: size.width * 0.50, y: size.height * 0.30)
        )
        ctx.stroke(roll, with: .color(foam.opacity(0.70)),
                   style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
    }

    /// White foam ridge running along the entire top edge of the big wave.
    private func drawBigWaveCrestRidge(ctx: inout GraphicsContext, size: CGSize) {
        var ridge = Path()
        let pts = bigWaveTopEdgePoints(size: size)
        ridge.move(to: pts[0].point)
        for seg in pts.dropFirst() {
            switch seg.kind {
            case .line:
                ridge.addLine(to: seg.point)
            case .curve(let c1, let c2):
                ridge.addCurve(to: seg.point, control1: c1, control2: c2)
            case .quad(let c):
                ridge.addQuadCurve(to: seg.point, control: c)
            }
        }
        ctx.stroke(ridge, with: .color(foam.opacity(0.92)),
                   style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
        // Thinner inner foam line below the crest for depth.
        var inner = Path()
        inner.move(to: CGPoint(x: 0, y: size.height * 0.56))
        inner.addCurve(
            to: CGPoint(x: size.width * 0.30, y: size.height * 0.30),
            control1: CGPoint(x: size.width * 0.06, y: size.height * 0.48),
            control2: CGPoint(x: size.width * 0.18, y: size.height * 0.34)
        )
        inner.addQuadCurve(
            to: CGPoint(x: size.width * 0.46, y: size.height * 0.33),
            control: CGPoint(x: size.width * 0.40, y: size.height * 0.26)
        )
        ctx.stroke(inner, with: .color(foam.opacity(0.50)),
                   style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
    }

    /// The iconic claw-fingers of foam fanning rightward from the crest.
    private func drawBigWaveClaws(ctx: inout GraphicsContext, size: CGSize) {
        // Origin band along the crest curl.
        let originPoints: [(CGFloat, CGFloat)] = [
            (0.24, 0.27), (0.30, 0.24), (0.36, 0.23), (0.42, 0.25),
            (0.48, 0.29), (0.52, 0.33), (0.45, 0.20), (0.39, 0.21),
        ]
        // Tip positions reaching toward the right side of the sky.
        let tipPoints: [(CGFloat, CGFloat)] = [
            (0.40, 0.12), (0.50, 0.08), (0.60, 0.10), (0.68, 0.15),
            (0.74, 0.22), (0.78, 0.30), (0.55, 0.06), (0.46, 0.05),
        ]
        for i in 0..<min(originPoints.count, tipPoints.count) {
            let oX = size.width * originPoints[i].0
            let oY = size.height * originPoints[i].1
            let tX = size.width * tipPoints[i].0
            let tY = size.height * tipPoints[i].1
            let dx = tX - oX
            let dy = tY - oY
            // Two control points for a graceful S-curl.
            let curl: CGFloat = i.isMultiple(of: 2) ? 1 : -1
            let c1 = CGPoint(x: oX + dx * 0.20 - curl * 14,
                             y: oY + dy * 0.45)
            let c2 = CGPoint(x: oX + dx * 0.75 + curl * 18,
                             y: tY + dy * 0.15)
            var claw = Path()
            claw.move(to: CGPoint(x: oX, y: oY))
            claw.addCurve(to: CGPoint(x: tX, y: tY), control1: c1, control2: c2)
            let width: CGFloat = CGFloat(2.4 + 2.0 * Double(7 - i) / 7.0)
            ctx.stroke(claw, with: .color(foam.opacity(0.92)),
                       style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
            // Inner ink line on the claw for ukiyo-e contour.
            ctx.stroke(claw, with: .color(ink.opacity(0.30)),
                       style: StrokeStyle(lineWidth: 0.7, lineCap: .round))
            // Droplet at the tip.
            let r: CGFloat = 4.5 + CGFloat(sin(Double(i))) * 1.5
            ctx.fill(Path(ellipseIn: CGRect(x: tX - r, y: tY - r, width: r * 2, height: r * 2)),
                     with: .color(foam))
            // A couple of smaller satellite droplets near the tip.
            for j in 1...2 {
                let off = CGFloat(j) * 8
                let sx = tX + CGFloat(cos(Double(i + j) * 1.7)) * off
                let sy = tY + CGFloat(sin(Double(i + j) * 1.3)) * off
                let sr: CGFloat = 1.5 + CGFloat(j) * 0.4
                ctx.fill(Path(ellipseIn: CGRect(x: sx - sr, y: sy - sr,
                                                width: sr * 2, height: sr * 2)),
                         with: .color(foam.opacity(0.85)))
            }
        }
    }

    /// Loose spray droplets sprinkled along the wave path.
    private func drawSpray(ctx: inout GraphicsContext, size: CGSize) {
        var rng = SeededRNG(seed: 814)
        for _ in 0..<32 {
            // Concentrate near the crest area.
            let x = size.width * (0.18 + CGFloat(rng.nextUnit()) * 0.68)
            let y = size.height * (0.08 + CGFloat(rng.nextUnit()) * 0.30)
            let r: CGFloat = 0.8 + CGFloat(rng.nextUnit()) * 2.4
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(foam.opacity(0.70 + CGFloat(rng.nextUnit()) * 0.25)))
        }
    }

    private func drawPaperGrain(ctx: inout GraphicsContext, size: CGSize) {
        let grain = (isDay ? Color.black : Color.white)
        var rng = SeededRNG(seed: 73171)
        let dotCount = Int(size.width * size.height / 1500)
        for _ in 0..<dotCount {
            let x = CGFloat(rng.nextUnit()) * size.width
            let y = CGFloat(rng.nextUnit()) * size.height
            let r = 0.5 + CGFloat(rng.nextUnit()) * 0.8
            let opacity = 0.020 + CGFloat(rng.nextUnit()) * 0.040
            ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                     with: .color(grain.opacity(opacity)))
        }
        let fiberCount = Int(size.width / 14)
        for _ in 0..<fiberCount {
            let x = CGFloat(rng.nextUnit()) * size.width
            let y = CGFloat(rng.nextUnit()) * size.height
            let length = 6 + CGFloat(rng.nextUnit()) * 12
            let angle = CGFloat(rng.nextUnit()) * 2 * .pi
            var fiber = Path()
            fiber.move(to: CGPoint(x: x, y: y))
            fiber.addLine(to: CGPoint(x: x + cos(angle) * length, y: y + sin(angle) * length))
            ctx.stroke(fiber, with: .color(grain.opacity(0.025 + CGFloat(rng.nextUnit()) * 0.025)),
                       style: StrokeStyle(lineWidth: 0.5, lineCap: .round))
        }
    }

    // MARK: big wave geometry

    /// The closed silhouette of the big wave — body shape, used for the fill.
    private func bigWavePath(size: CGSize) -> Path {
        var p = Path()
        let pts = bigWaveTopEdgePoints(size: size)
        p.move(to: pts[0].point)
        for seg in pts.dropFirst() {
            switch seg.kind {
            case .line:
                p.addLine(to: seg.point)
            case .curve(let c1, let c2):
                p.addCurve(to: seg.point, control1: c1, control2: c2)
            case .quad(let c):
                p.addQuadCurve(to: seg.point, control: c)
            }
        }
        // close down the right, across the bottom, back up the left
        p.addLine(to: CGPoint(x: size.width, y: size.height))
        p.addLine(to: CGPoint(x: 0, y: size.height))
        p.closeSubpath()
        return p
    }

    /// Anchor points along the top edge of the big wave (left side rising, crest curl,
    /// curl-back descent, long trough down to the right side meeting the secondary wave).
    private func bigWaveTopEdgePoints(size: CGSize) -> [Segment] {
        let W = size.width, H = size.height
        return [
            Segment(point: CGPoint(x: 0, y: H * 1.02), kind: .line),
            // up the left edge
            Segment(point: CGPoint(x: 0, y: H * 0.55), kind: .line),
            // big arch up to the crest
            Segment(point: CGPoint(x: W * 0.32, y: H * 0.22),
                    kind: .curve(c1: CGPoint(x: W * 0.04, y: H * 0.38),
                                  c2: CGPoint(x: W * 0.18, y: H * 0.24))),
            // crest tip — slight curl back rightward and downward
            Segment(point: CGPoint(x: W * 0.46, y: H * 0.30),
                    kind: .quad(c: CGPoint(x: W * 0.42, y: H * 0.16))),
            // descent into the trough
            Segment(point: CGPoint(x: W * 0.60, y: H * 0.52),
                    kind: .curve(c1: CGPoint(x: W * 0.52, y: H * 0.38),
                                  c2: CGPoint(x: W * 0.56, y: H * 0.48))),
            // valley / trough — meets the secondary wave's left side
            Segment(point: CGPoint(x: W * 0.78, y: H * 0.68),
                    kind: .curve(c1: CGPoint(x: W * 0.66, y: H * 0.62),
                                  c2: CGPoint(x: W * 0.72, y: H * 0.68))),
        ]
    }
}

private struct Segment {
    let point: CGPoint
    let kind: Kind
    enum Kind {
        case line
        case curve(c1: CGPoint, c2: CGPoint)
        case quad(c: CGPoint)
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
