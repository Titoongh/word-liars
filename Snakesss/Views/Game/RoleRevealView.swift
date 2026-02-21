import SwiftUI

// MARK: - RoleRevealView

/// Pass-and-play role reveal for one player. Shows a "pass to [name]" screen first,
/// then reveals role on tap. Transitions to next player or mongoose announcement.
struct RoleRevealView: View {
    let player: Player
    let playerIndex: Int
    let totalPlayers: Int
    let roundNumber: Int
    let onDone: () -> Void

    @State private var isRevealed = false

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            if isRevealed {
                revealedContent
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            } else {
                PassPhoneOverlay(
                    playerName: player.name,
                    onTap: {
                        withAnimation(SnakesssAnimation.reveal) {
                            isRevealed = true
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(SnakesssAnimation.reveal, value: isRevealed)
        .onChange(of: player.id) { _, _ in
            // Reset reveal state when player changes
            isRevealed = false
        }
    }

    // MARK: - Revealed Content

    private var revealedContent: some View {
        VStack(spacing: 0) {
            // Header
            roundBadge
                .padding(.top, SnakesssSpacing.spacing8)
                .onAppear { SnakesssHaptic.heavy() }

            Spacer()

            // Role card
            roleCard

            Spacer()

            // Continue button
            Button("Done — Pass the phone") {
                SnakesssHaptic.medium()
                withAnimation(SnakesssAnimation.standard) {
                    isRevealed = false
                    // Small delay so the hide animation plays first
                }
                // Slight delay to let hide animate
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(200))
                    onDone()
                }
            }
            .buttonStyle(SnakesssPrimaryButtonStyle())
            .padding(.horizontal, SnakesssSpacing.screenPadding)
            .padding(.bottom, SnakesssSpacing.spacing12)
        }
    }

    private var roundBadge: some View {
        VStack(spacing: SnakesssSpacing.spacing2) {
            Text("Round \(roundNumber) of \(GameViewModel.totalRounds)")
                .microStyle(color: SnakesssTheme.textMuted)

            Text("Player \(playerIndex + 1) of \(totalPlayers)")
                .microStyle(color: SnakesssTheme.textSecondary)
        }
    }

    private var roleCard: some View {
        VStack(spacing: SnakesssSpacing.spacing6) {
            // Player name
            Text(player.name)
                .font(SnakesssTypography.headline)
                .foregroundStyle(SnakesssTheme.textSecondary)

            // Role emoji + name
            if let role = player.role {
                VStack(spacing: SnakesssSpacing.spacing4) {
                    Text(role.emoji)
                        .font(.system(size: 72))
                        .shadow(color: role.glowColor, radius: 24)

                    Text("YOUR ROLE")
                        .microStyle(color: SnakesssTheme.textMuted)

                    Text(role.displayName.uppercased())
                        .font(SnakesssTypography.title)
                        .foregroundStyle(role.color)
                        .shadow(color: role.glowColor, radius: 12)

                    Text(role.flavorText)
                        .font(SnakesssTypography.body)
                        .foregroundStyle(SnakesssTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SnakesssSpacing.spacing8)
                }
                .padding(SnakesssSpacing.spacing8)
                .background(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .fill(SnakesssTheme.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                                .strokeBorder(role.color.opacity(0.30), lineWidth: 1.5)
                        )
                )
                .shadow(color: role.glowColor, radius: 24)
                .padding(.horizontal, SnakesssSpacing.screenPadding)
            }
        }
    }
}
