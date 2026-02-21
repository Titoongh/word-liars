import SwiftUI

// MARK: - Scale Texture Modifier

/// Applies a repeating snake-scale texture overlay to any view.
/// Uses a programmatic diamond/rhombus pattern when no image asset is available.
/// - Pattern: 40×40pt, rgba(255,255,255,0.025) — subtle, non-distracting
struct ScaleTextureModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(
            ScalePatternView()
                .allowsHitTesting(false)
        )
    }
}

// MARK: - Programmatic Scale Pattern

/// Canvas-drawn diamond/rhombus tiling pattern simulating snake scales.
/// Used as fallback when no scale_texture image asset is available.
private struct ScalePatternView: View {
    var body: some View {
        Canvas { context, size in
            let tileWidth: CGFloat = 40
            let tileHeight: CGFloat = 40
            let cols = Int(ceil(size.width / tileWidth)) + 1
            let rows = Int(ceil(size.height / tileHeight)) + 1

            for row in 0...rows {
                for col in 0...cols {
                    let xOffset: CGFloat = (row % 2 == 0) ? 0 : tileWidth / 2
                    let x = CGFloat(col) * tileWidth + xOffset - tileWidth / 2
                    let y = CGFloat(row) * tileHeight - tileHeight / 2

                    let cx = x + tileWidth / 2
                    let cy = y + tileHeight / 2
                    let halfW = tileWidth * 0.42
                    let halfH = tileHeight * 0.42

                    var diamond = Path()
                    diamond.move(to: CGPoint(x: cx, y: cy - halfH))
                    diamond.addLine(to: CGPoint(x: cx + halfW, y: cy))
                    diamond.addLine(to: CGPoint(x: cx, y: cy + halfH))
                    diamond.addLine(to: CGPoint(x: cx - halfW, y: cy))
                    diamond.closeSubpath()

                    context.stroke(
                        diamond,
                        with: .color(.white.opacity(0.025)),
                        lineWidth: 0.5
                    )
                }
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply the snake-scale texture overlay to any view.
    func scaleTexture() -> some View {
        modifier(ScaleTextureModifier())
    }
}

// MARK: - Preview

#Preview("Scale Texture") {
    ZStack {
        Color(hex: "#0A1A10")
            .scaleTexture()

        VStack {
            Text("Snakesss")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("TRUST NOBODY")
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .tracking(3)
                .foregroundStyle(Color(hex: "#7A9E80"))
        }
    }
    .ignoresSafeArea()
}
