import SwiftUI

// MARK: - Secondary Button Style

/// Secondary / outline button style.
/// - Shape: Capsule
/// - Fill: transparent
/// - Border: 2pt borderActive (green @40%)
/// - Label: label weight 700, color accentPrimary
/// - Pressed: fill borderSubtle, scale 0.97
struct SnakesssSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SnakesssTypography.label)
            .foregroundStyle(SnakesssTheme.accentPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(
                Capsule()
                    .fill(configuration.isPressed ? SnakesssTheme.borderSubtle : Color.clear)
                    .overlay(
                        Capsule()
                            .strokeBorder(SnakesssTheme.borderActive, lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(SnakesssAnimation.bouncy, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Secondary Button") {
    VStack(spacing: 24) {
        Button("Game History") {}
            .buttonStyle(SnakesssSecondaryButtonStyle())

        Button("Skip Discussion") {}
            .buttonStyle(SnakesssSecondaryButtonStyle())
    }
    .padding(28)
    .background(Color(hex: "#0A1A10"))
}
