import SwiftUI

// MARK: - SnakeRevealView

/// Eyes-closed secret reveal for one Snake. Shows correct answer + other snake names.
/// Pass-and-play pattern: prompt to pass, then reveal on tap.
struct SnakeRevealView: View {
    let snake: Player
    let snakeIndex: Int
    let totalSnakes: Int
    let allSnakeNames: [String]
    let correctAnswer: String
    let question: Question?
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
                snakePassOverlay
                    .transition(.opacity)
            }
        }
        .animation(SnakesssAnimation.reveal, value: isRevealed)
        .onChange(of: snake.id) { _, _ in
            isRevealed = false
        }
    }

    // MARK: - Pass Overlay (eyes closed prompt)

    private var snakePassOverlay: some View {
        ZStack {
            SnakesssTheme.overlayScrim.ignoresSafeArea()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: SnakesssSpacing.spacing4) {
                Spacer()

                Text("All players — close your eyes")
                    .microStyle(color: SnakesssTheme.textSecondary)

                Text("🐍")
                    .font(.system(size: 64))

                Text("Pass to")
                    .microStyle(color: SnakesssTheme.textMuted)

                Text(snake.name)
                    .font(SnakesssTypography.playerName)
                    .foregroundStyle(SnakesssTheme.textPrimary)

                Text("Snake \(snakeIndex + 1) of \(totalSnakes)")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textMuted)

                Spacer()

                Text("Tap to reveal secret")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textMuted)
                    .padding(.bottom, SnakesssSpacing.spacing12)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            SnakesssHaptic.heavy()
            withAnimation(SnakesssAnimation.reveal) {
                isRevealed = true
            }
        }
    }

    // MARK: - Revealed Content

    private var revealedContent: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: SnakesssSpacing.spacing6) {
                // Header
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text(snake.name)
                        .font(SnakesssTypography.headline)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                    Text("You are a Snake 🐍")
                        .font(SnakesssTypography.label)
                        .foregroundStyle(SnakesssTheme.snakeColor)
                }

                // Correct answer card
                VStack(spacing: SnakesssSpacing.spacing2) {
                    Text("The correct answer is")
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.textMuted)

                    Text(answerLabel)
                        .font(SnakesssTypography.title)
                        .foregroundStyle(SnakesssTheme.truthGold)
                        .goldGlow()

                    if let text = answerText {
                        Text(text)
                            .font(SnakesssTypography.body)
                            .foregroundStyle(SnakesssTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(SnakesssSpacing.cardPadding)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .fill(SnakesssTheme.truthGoldDim)
                        .overlay(
                            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                                .strokeBorder(SnakesssTheme.truthGold.opacity(0.30), lineWidth: 1.5)
                        )
                )

                // Other snakes
                if allSnakeNames.count > 1 {
                    VStack(spacing: SnakesssSpacing.spacing2) {
                        Text("Your fellow snakes:")
                            .font(SnakesssTypography.caption)
                            .foregroundStyle(SnakesssTheme.textMuted)

                        let otherSnakes = allSnakeNames.filter { $0 != snake.name }
                        ForEach(otherSnakes, id: \.self) { name in
                            Text("🐍 \(name)")
                                .font(SnakesssTypography.bodyLarge)
                                .foregroundStyle(SnakesssTheme.snakeColor)
                        }
                    }
                }

                Text("Lead the humans astray. Vote 'Snake' during voting.")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(SnakesssSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard)
                    .fill(SnakesssTheme.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: SnakesssRadius.radiusLargeCard)
                            .strokeBorder(SnakesssTheme.snakeColor.opacity(0.25), lineWidth: 1.5)
                    )
            )
            .snakesssGlow(SnakessssShadow.glowAccent)
            .padding(.horizontal, SnakesssSpacing.screenPadding)

            Spacer()

            Button("Done — Hide screen") {
                SnakesssHaptic.medium()
                withAnimation(SnakesssAnimation.standard) {
                    isRevealed = false
                }
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

    // MARK: - Helpers

    private var answerLabel: String {
        correctAnswer.uppercased()
    }

    private var answerText: String? {
        guard let q = question else { return nil }
        switch correctAnswer.uppercased() {
        case "A": return q.choices.a
        case "B": return q.choices.b
        case "C": return q.choices.c
        default: return nil
        }
    }
}
