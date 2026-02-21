import SwiftUI

// MARK: - SnakeRevealView

/// Eyes-closed secret reveal for one Snake. Shows correct answer + other snake names.
/// Pass-and-play pattern: eyes-closed prompt → pass → reveal on tap → eyes-open (last snake).
struct SnakeRevealView: View {
    let snake: Player
    let snakeIndex: Int
    let totalSnakes: Int
    let allSnakeNames: [String]
    let correctAnswer: String
    let question: Question?
    let onDone: () -> Void

    private enum RevealPhase { case closedEyes, passing, revealed, openEyes }

    @State private var revealPhase: RevealPhase

    init(snake: Player, snakeIndex: Int, totalSnakes: Int, allSnakeNames: [String],
         correctAnswer: String, question: Question?, onDone: @escaping () -> Void) {
        self.snake = snake
        self.snakeIndex = snakeIndex
        self.totalSnakes = totalSnakes
        self.allSnakeNames = allSnakeNames
        self.correctAnswer = correctAnswer
        self.question = question
        self.onDone = onDone
        // Show "close your eyes" prompt only for the first snake
        _revealPhase = State(initialValue: snakeIndex == 0 ? .closedEyes : .passing)
    }

    private var isLastSnake: Bool { snakeIndex + 1 == totalSnakes }

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            switch revealPhase {
            case .closedEyes:
                closedEyesView
                    .transition(.opacity)
            case .passing:
                snakePassOverlay
                    .transition(.opacity)
            case .revealed:
                revealedContent
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            case .openEyes:
                openEyesView
                    .transition(.opacity)
            }
        }
        .animation(SnakesssAnimation.reveal, value: revealPhase)
        .onChange(of: snake.id) { _, _ in
            revealPhase = snakeIndex == 0 ? .closedEyes : .passing
        }
    }

    // MARK: - Eyes Closed Prompt (State A)

    private var closedEyesView: some View {
        ZStack {
            SnakesssTheme.overlayScrim.ignoresSafeArea()

            VStack(spacing: SnakesssSpacing.spacing6) {
                Spacer()

                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(SnakesssTheme.textMuted)

                Text("Everyone close your eyes")
                    .font(SnakesssTypography.headline)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Snakes: wait for your tap cue")
                    .font(SnakesssTypography.body)
                    .foregroundStyle(SnakesssTheme.textSecondary)
                    .multilineTextAlignment(.center)

                Spacer()

                Text("HOST: Tap when ready →")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textMuted)
                    .padding(.bottom, SnakesssSpacing.spacing12)
            }
            .padding(.horizontal, SnakesssSpacing.screenPadding)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            SnakesssHaptic.medium()
            withAnimation(SnakesssAnimation.reveal) {
                revealPhase = .passing
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Everyone close your eyes. Snakes: wait for your tap cue. HOST: Tap when ready")
        .accessibilityAction {
            SnakesssHaptic.medium()
            withAnimation(SnakesssAnimation.reveal) { revealPhase = .passing }
        }
    }

    // MARK: - Pass Overlay (State B)

    private var snakePassOverlay: some View {
        ZStack {
            SnakesssTheme.overlayScrim.ignoresSafeArea()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: SnakesssSpacing.spacing4) {
                Spacer()

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
                revealPhase = .revealed
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Pass to \(snake.name). Snake \(snakeIndex + 1) of \(totalSnakes). Tap to reveal secret")
        .accessibilityAction {
            SnakesssHaptic.heavy()
            withAnimation(SnakesssAnimation.reveal) { revealPhase = .revealed }
        }
    }

    // MARK: - Revealed Content (State C)

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
                    Text("CORRECT ANSWER")
                        .microStyle(color: SnakesssTheme.textMuted)

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
                        Text("YOUR FELLOW SNAKES")
                            .microStyle(color: SnakesssTheme.textMuted)

                        let otherSnakes = allSnakeNames.indices
                            .filter { $0 != snakeIndex }
                            .map { allSnakeNames[$0] }
                        ForEach(otherSnakes, id: \.self) { name in
                            Text("🐍 \(name)")
                                .font(SnakesssTypography.bodyLarge)
                                .foregroundStyle(SnakesssTheme.snakeColor)
                        }
                    }
                }

                VStack(spacing: SnakesssSpacing.spacing1) {
                    Text("Remember: vote \"Snake\" only.")
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.snakeColor)
                    Text("Any other vote = lose points.")
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.danger)
                }
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
            .snakesssGlow(SnakesssShadow.glowAccent)
            .padding(.horizontal, SnakesssSpacing.screenPadding)

            Spacer()

            Button("Done — Hide This Screen") {
                SnakesssHaptic.medium()
                withAnimation(SnakesssAnimation.standard) {
                    if isLastSnake {
                        revealPhase = .openEyes
                    } else {
                        revealPhase = .passing
                    }
                }
                if !isLastSnake {
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(200))
                        onDone()
                    }
                }
            }
            .buttonStyle(SnakesssPrimaryButtonStyle())
            .padding(.horizontal, SnakesssSpacing.screenPadding)
            .padding(.bottom, SnakesssSpacing.spacing12)
        }
    }

    // MARK: - Open Eyes Prompt (State D — last snake only)

    private var openEyesView: some View {
        ZStack {
            SnakesssTheme.overlayScrim.ignoresSafeArea()

            VStack(spacing: SnakesssSpacing.spacing6) {
                Spacer()

                Image(systemName: "eye.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(SnakesssTheme.accentPrimary)
                    .accentGlow()

                Text("Everyone open your eyes")
                    .font(SnakesssTypography.headline)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Snakes know the answer.\nThe discussion begins.")
                    .font(SnakesssTypography.body)
                    .foregroundStyle(SnakesssTheme.textSecondary)
                    .multilineTextAlignment(.center)

                Spacer()

                Button("Start Discussion →") {
                    SnakesssHaptic.medium()
                    onDone()
                }
                .buttonStyle(SnakesssPrimaryButtonStyle())
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .padding(.bottom, SnakesssSpacing.spacing12)
            }
            .padding(.horizontal, SnakesssSpacing.screenPadding)
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
