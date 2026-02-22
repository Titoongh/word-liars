import SwiftUI

// MARK: - Pass Phone Overlay

/// Full-screen interstitial overlay for passing the phone to the next player.
struct PassPhoneOverlay: View {
    let playerName: String
    var caption: LocalizedStringKey = "passPhone.tapToRevealRole.caption"
    let onTap: () -> Void

    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Background: scrim + scale texture
            SnakesssTheme.overlayScrim
                .scaleTexture()
                .ignoresSafeArea()

            // Green radial overlay for atmosphere
            SnakesssTheme.greenRadialOverlay
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: SnakesssSpacing.spacing4) {
                Spacer()

                // "PASS TO" label
                Text("passPhone.passTo.label")
                    .microStyle(color: SnakesssTheme.textSecondary)

                // Player name with breathing pulse animation
                Text(playerName)
                    .font(SnakesssTypography.playerName)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                    .scaleEffect(isPulsing ? 0.97 : 1.0)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isPulsing
                    )

                Spacer()

                // Caption
                Text(caption)
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textMuted)
                    .padding(.bottom, SnakesssSpacing.spacing12)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            SnakesssHaptic.medium()
            onTap()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(String(localized: "passPhone.passTo.accessibility \(playerName)"))
        .accessibilityHint(Text(caption))
        .accessibilityAction {
            SnakesssHaptic.medium()
            onTap()
        }
        .onAppear {
            if !reduceMotion { isPulsing = true }
        }
    }
}

// MARK: - Preview

#Preview("Pass Phone Overlay") {
    PassPhoneOverlay(playerName: "Carol") {
        print("Tapped")
    }
    .background(Color(hex: "#0A1A10"))
}
