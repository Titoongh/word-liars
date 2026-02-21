import SwiftUI

// MARK: - RoleRevealView

/// Pass-and-play role reveal for one player. Shows a "pass to [name]" screen first,
/// then reveals role via hold-to-reveal gesture. Role auto-hides on release.
struct RoleRevealView: View {
    let player: Player
    let playerIndex: Int
    let totalPlayers: Int
    let roundNumber: Int
    let totalRounds: Int
    let onDone: () -> Void

    @State private var isRevealed = false

    // M3 + S8: Hold-to-reveal card flip state
    @GestureState private var isHolding = false
    @State private var cardFlipX: CGFloat = 1.0
    @State private var showRoleFace = false

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture() // M1
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
            isRevealed = false
            resetFlip()
        }
        .onChange(of: isHolding) { _, holding in
            handleHold(holding)
        }
    }

    // MARK: - Revealed Content

    private var revealedContent: some View {
        VStack(spacing: 0) {
            // Header
            roundBadge
                .padding(.top, SnakesssSpacing.spacing8)
                .onAppear { SnakesssHaptic.medium() }

            Spacer()

            // Hold-to-reveal role card (M3 + S8)
            holdableRoleCard

            Spacer()

            // Hint label
            Text("Hold to reveal · Release to hide")
                .font(SnakesssTypography.micro)
                .foregroundStyle(SnakesssTheme.textMuted)
                .tracking(1)
                .padding(.bottom, SnakesssSpacing.spacing2)

            // Continue button
            Button("Done — Pass the phone") {
                SnakesssHaptic.medium()
                withAnimation(SnakesssAnimation.standard) {
                    isRevealed = false
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(200))
                    resetFlip()
                    onDone()
                }
            }
            .buttonStyle(SnakesssPrimaryButtonStyle())
            .padding(.horizontal, SnakesssSpacing.screenPadding)
            .padding(.bottom, SnakesssSpacing.spacing12)
        }
    }

    // MARK: - Holdable Role Card (M3 + S8)

    private var holdableRoleCard: some View {
        ZStack {
            if showRoleFace {
                roleFaceContent
            } else {
                blankCardFace
            }
        }
        .scaleEffect(x: cardFlipX, y: 1.0, anchor: .center)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isHolding) { _, state, _ in state = true }
        )
        .padding(.horizontal, SnakesssSpacing.screenPadding)
    }

    private var blankCardFace: some View {
        VStack(spacing: SnakesssSpacing.spacing6) {
            Text("👁‍🗨")
                .font(.system(size: 48))
                .foregroundStyle(SnakesssTheme.textMuted)

            Text("HOLD TO REVEAL")
                .microStyle(color: SnakesssTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(SnakesssSpacing.spacing16)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard) // M2
                .fill(SnakesssTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard) // M2
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 2)
                )
        )
    }

    private var roleFaceContent: some View {
        Group {
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
                .frame(maxWidth: .infinity)
                .padding(SnakesssSpacing.spacing8)
                .background(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard) // M2
                        .fill(SnakesssTheme.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard) // M2
                                .strokeBorder(role.color.opacity(0.40), lineWidth: 2)
                        )
                )
                .shadow(color: role.glowColor, radius: 24)
            }
        }
    }

    // MARK: - Flip Helpers

    private func handleHold(_ holding: Bool) {
        if holding {
            // Phase 1: scaleX → 0 (mid-flip)
            withAnimation(.linear(duration: 0.15)) {
                cardFlipX = 0
            }
            // Phase 2: switch to role face, scaleX → 1 (reveal)
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(150))
                showRoleFace = true
                SnakesssHaptic.heavy()
                withAnimation(SnakesssAnimation.reveal) {
                    cardFlipX = 1
                }
            }
        } else {
            // Hide: quick flip back to blank
            withAnimation(.linear(duration: 0.1)) {
                cardFlipX = 0
            }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                showRoleFace = false
                withAnimation(.linear(duration: 0.12)) {
                    cardFlipX = 1
                }
            }
        }
    }

    private func resetFlip() {
        cardFlipX = 1.0
        showRoleFace = false
    }

    // MARK: - Round Badge

    private var roundBadge: some View {
        VStack(spacing: SnakesssSpacing.spacing2) {
            Text("Round \(roundNumber) of \(totalRounds)")
                .microStyle(color: SnakesssTheme.textMuted)

            Text("Player \(playerIndex + 1) of \(totalPlayers)")
                .microStyle(color: SnakesssTheme.textSecondary)
        }
    }
}
