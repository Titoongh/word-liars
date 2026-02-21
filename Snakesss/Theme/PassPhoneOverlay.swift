import SwiftUI

// MARK: - Pass Phone Overlay

/// Full-screen interstitial overlay for passing the phone to the next player.
/// - Layout: "PASS TO" micro label + player name (playerName style, breathing pulse) + "Tap to reveal" caption
/// - Uses overlayScrim background with scale texture
/// - Breathing pulse: player name scales 1.0 ↔ 0.97, 2s easeInOut loop
struct PassPhoneOverlay: View {
    let playerName: String
    var caption: String = "Tap to reveal your role"
    let onTap: () -> Void

    @State private var isPulsing = false

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
                Text("Pass to")
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

                // "Tap to reveal" caption
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
        .onAppear {
            isPulsing = true
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
