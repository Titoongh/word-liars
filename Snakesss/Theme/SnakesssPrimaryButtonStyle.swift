import SwiftUI

// MARK: - Primary Button Style

/// Primary CTA button style.
/// - Shape: Capsule (radiusFull)
/// - Fill: Linear gradient accentPrimary → accentDeep
/// - Shadow: glowAccent (green glow)
/// - Inner highlight: top half rgba(255,255,255,0.10)
/// - Pressed: scale 0.95 + .light haptic + reduced shadow
/// - Disabled: opacity 0.4, no glow
/// - Min height: 56pt
struct SnakesssPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SnakesssTypography.bodyLarge)
            .foregroundStyle(SnakesssTheme.bgBase)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(
                Capsule()
                    .fill(SnakesssTheme.buttonPrimaryGradient)
                    .overlay(
                        // Inner highlight — top half shimmer for physical depth illusion
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.10),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    )
            )
            .shadow(
                color: SnakesssTheme.accentGlow,
                radius: configuration.isPressed ? 8 : 16,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(SnakesssAnimation.bouncy, value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.4)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    SnakesssHaptic.light()
                }
            }
    }
}

// MARK: - Preview

#Preview("Primary Button") {
    VStack(spacing: 24) {
        Button("New Game") {}
            .buttonStyle(SnakesssPrimaryButtonStyle())

        Button("Start Game →") {}
            .buttonStyle(SnakesssPrimaryButtonStyle())

        Button("Disabled") {}
            .buttonStyle(SnakesssPrimaryButtonStyle())
            .disabled(true)
    }
    .padding(28)
    .background(Color(hex: "#0A1A10"))
}
