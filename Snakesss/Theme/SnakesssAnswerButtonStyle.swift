import SwiftUI

// MARK: - Answer Button Style

/// A/B/C trivia choice button style.
/// - Shape: radiusXl (20pt)
/// - Fill: bgElevated
/// - Border: 2pt borderSubtle (default) / accentPrimary (selected)
/// - Layout: [36×36 letter badge | answer text | Spacer]
/// - Letter badge: circle, accentPrimary @10% fill, 1pt borderActive border, micro label
/// - Selected: border → accentPrimary, 8px accent glow, scale 1.02 spring
struct SnakesssAnswerButtonStyle: ButtonStyle {
    let letter: String
    let isSelected: Bool

    init(letter: String, isSelected: Bool = false) {
        self.letter = letter
        self.isSelected = isSelected
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: SnakesssSpacing.spacing3) {
            // Letter badge
            ZStack {
                Circle()
                    .fill(SnakesssTheme.accentPrimary.opacity(0.10))
                    .overlay(
                        Circle()
                            .strokeBorder(SnakesssTheme.borderActive, lineWidth: 1)
                    )
                    .frame(width: 36, height: 36)

                Text(letter)
                    .font(SnakesssTypography.micro)
                    .tracking(0)
                    .foregroundStyle(SnakesssTheme.accentPrimary)
            }

            // Answer text
            configuration.label
                .font(SnakesssTypography.answer)
                .foregroundStyle(SnakesssTheme.textPrimary)

            Spacer()
        }
        .padding(.horizontal, SnakesssSpacing.spacing4)
        .padding(.vertical, SnakesssSpacing.spacing3)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusXl)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusXl)
                        .strokeBorder(
                            isSelected
                                ? SnakesssTheme.accentPrimary
                                : SnakesssTheme.borderSubtle,
                            lineWidth: 2
                        )
                )
        )
        .shadow(
            color: isSelected ? SnakesssTheme.accentGlow : .clear,
            radius: 8,
            x: 0,
            y: 0
        )
        .scaleEffect(isSelected ? 1.02 : (configuration.isPressed ? 0.98 : 1.0))
        .animation(SnakesssAnimation.bouncy, value: isSelected)
        .animation(SnakesssAnimation.bouncy, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Answer Buttons") {
    VStack(spacing: 12) {
        Button("Switzerland") {}
            .buttonStyle(SnakesssAnswerButtonStyle(letter: "A", isSelected: true))

        Button("Belgium") {}
            .buttonStyle(SnakesssAnswerButtonStyle(letter: "B"))

        Button("Germany") {}
            .buttonStyle(SnakesssAnswerButtonStyle(letter: "C"))
    }
    .padding(28)
    .background(Color(hex: "#0A1A10"))
}
