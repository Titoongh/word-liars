import SwiftUI

// MARK: - Typography Scale

/// All 13 type roles for Snakesss, using SF Pro Rounded (zero-embedding overhead).
/// Timer uses SF Pro Monospaced for tabular digit rendering.
/// All sizes support Dynamic Type via system text styles.
enum SnakesssTypography {
    /// Display — 52pt Black, rounded. Headings like the app name.
    static let display    = Font.system(size: 52, weight: .black, design: .rounded)

    /// Title — Large Title style, Heavy, rounded. Screen titles.
    static let title      = Font.system(.largeTitle, design: .rounded).weight(.heavy)

    /// Headline — Title2 style, Bold, rounded. Section headers.
    static let headline   = Font.system(.title2, design: .rounded).weight(.bold)

    /// Question — Title3 style, Heavy (ExtraBold), rounded. Question text on center-table screen.
    static let question   = Font.system(.title3, design: .rounded).weight(.heavy)

    /// Answer — Body style, Bold, rounded. Answer choice text.
    static let answer     = Font.system(.body, design: .rounded).weight(.bold)

    /// Body Large — Body style, SemiBold, rounded. Button labels, prominent body.
    static let bodyLarge  = Font.system(.body, design: .rounded).weight(.semibold)

    /// Body — Body style, Medium, rounded. Standard body text.
    static let body       = Font.system(.body, design: .rounded).weight(.medium)

    /// Label — Subheadline style, SemiBold, rounded. Input labels, UI labels.
    static let label      = Font.system(.subheadline, design: .rounded).weight(.semibold)

    /// Caption — Caption style, Medium, rounded. Captions, hints, instructions.
    static let caption    = Font.system(.caption, design: .rounded).weight(.medium)

    /// Micro — Caption2 style, Bold, rounded. ALL CAPS category labels, role badges.
    /// Use with `.tracking(3)` and `.textCase(.uppercase)`.
    static let micro      = Font.system(.caption2, design: .rounded).weight(.bold)

    /// Score — 64pt Black, rounded. Large score display.
    static let score      = Font.system(size: 64, weight: .black, design: .rounded)

    /// Timer — 64pt Bold, monospaced. Tabular digit countdown.
    static let timer      = Font.system(size: 64, weight: .bold, design: .monospaced)

    /// Player Name — Title2 style, Heavy, rounded. Player name on pass-phone screens.
    static let playerName = Font.system(.title2, design: .rounded).weight(.heavy)
}

// MARK: - Typography View Modifiers

extension View {
    /// Apply micro style with proper ALL CAPS tracking
    func microStyle(color: Color) -> some View {
        self
            .font(SnakesssTypography.micro)
            .tracking(3)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

// MARK: - Preview

#Preview("Typography Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Text("Display — App Name")
                    .font(SnakesssTypography.display)
                    .foregroundStyle(.white)

                Text("Title — Screen Title")
                    .font(SnakesssTypography.title)
                    .foregroundStyle(.white)

                Text("Headline — Section Header")
                    .font(SnakesssTypography.headline)
                    .foregroundStyle(.white)

                Text("Question — Center Table Question Text")
                    .font(SnakesssTypography.question)
                    .foregroundStyle(.white)

                Text("Answer — A/B/C Choices")
                    .font(SnakesssTypography.answer)
                    .foregroundStyle(.white)

                Text("Body Large — Button Labels")
                    .font(SnakesssTypography.bodyLarge)
                    .foregroundStyle(.white)

                Text("Body — Standard Text")
                    .font(SnakesssTypography.body)
                    .foregroundStyle(.white)

                Text("Label — UI Labels")
                    .font(SnakesssTypography.label)
                    .foregroundStyle(.white)

                Text("Caption — Hints and Instructions")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(.white)

                Text("MICRO — CATEGORY LABELS")
                    .font(SnakesssTypography.micro)
                    .tracking(3)
                    .foregroundStyle(.white)
            }

            Divider().overlay(.white.opacity(0.2))

            Group {
                Text("Score: 42")
                    .font(SnakesssTypography.score)
                    .foregroundStyle(.white)

                Text("1:28")
                    .font(SnakesssTypography.timer)
                    .foregroundStyle(.white)

                Text("Player Name — Alice")
                    .font(SnakesssTypography.playerName)
                    .foregroundStyle(.white)
            }
        }
        .padding(24)
    }
    .background(Color(hex: "#0A1A10"))
}
