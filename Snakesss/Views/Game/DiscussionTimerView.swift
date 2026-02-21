import SwiftUI

// MARK: - DiscussionTimerView

/// 2-minute countdown timer shown center-table during group discussion.
/// Visual urgency scaling: green → gold (≤30s) → red (≤10s).
struct DiscussionTimerView: View {
    let question: Question
    let timeRemaining: Int
    let mongooseName: String
    let onSkip: () -> Void

    @State private var isGlowPulsing = false

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
                .scaleTexture() // M1
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                // Header
                Text("Discussion")
                    .microStyle(color: SnakesssTheme.textMuted)
                    .padding(.top, SnakesssSpacing.spacing8)

                Spacer()

                // Timer ring + digits
                timerDisplay

                Spacer()

                // Question recap (for easy reference during discussion)
                questionRecap
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                    .padding(.bottom, SnakesssSpacing.spacing4)

                // Mongoose chip (persistent reminder)
                MongooseChipView(mongooseName: mongooseName)
                    .padding(.bottom, SnakesssSpacing.spacing6)

                // Skip button
                Button("Skip Discussion → Vote") {
                    onSkip()
                }
                .buttonStyle(SnakesssSecondaryButtonStyle())
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .padding(.bottom, SnakesssSpacing.spacing12)
            }
        }
        .onChange(of: timeRemaining) { _, newValue in
            // M4: Haptic triggers
            if newValue == 30 { SnakesssHaptic.light() }
            if newValue <= 10 && newValue > 0 { SnakesssHaptic.medium() }
            if newValue == 0 { SnakesssHaptic.timerEnd() }
            // Trigger glow pulse when entering danger zone
            if newValue == 10 {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isGlowPulsing = true
                }
            }
        }
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(SnakesssTheme.bgElevated, lineWidth: 8)
                .frame(width: 220, height: 220)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    timerColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: timeRemaining) // S4: linear for ring stroke
                // Glow pulse at ≤10s
                .shadow(
                    color: timerColor.opacity(isGlowPulsing ? 0.6 : 0.3),
                    radius: isGlowPulsing ? 20 : 8
                )

            // Time digits
            VStack(spacing: 2) {
                Text(timeString)
                    .font(SnakesssTypography.timer)
                    .foregroundStyle(timerColor)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(SnakesssAnimation.standard, value: timeRemaining)

                Text("remaining")
                    .font(SnakesssTypography.micro)
                    .foregroundStyle(SnakesssTheme.textMuted)
                    .tracking(2)
            }
        }
    }

    // MARK: - Question Recap

    private var questionRecap: some View {
        VStack(alignment: .leading, spacing: SnakesssSpacing.spacing3) {
            Text(question.question)
                .font(SnakesssTypography.label)
                .foregroundStyle(SnakesssTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: SnakesssSpacing.spacing3) {
                miniAnswer(letter: "A", text: question.choices.a)
                miniAnswer(letter: "B", text: question.choices.b)
                miniAnswer(letter: "C", text: question.choices.c)
            }
        }
        .padding(SnakesssSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                .fill(SnakesssTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusCard)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
    }

    private func miniAnswer(letter: String, text: String) -> some View {
        VStack(spacing: SnakesssSpacing.spacing1) {
            Text(letter)
                .font(SnakesssTypography.micro)
                .foregroundStyle(SnakesssTheme.accentPrimary)
                .tracking(0)
            Text(text)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(SnakesssTheme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Computed

    private var progress: CGFloat {
        CGFloat(timeRemaining) / 120.0
    }

    private var timerColor: Color {
        if timeRemaining <= 10 { return SnakesssTheme.danger }
        if timeRemaining <= 30 { return SnakesssTheme.truthGold }
        return SnakesssTheme.accentPrimary
    }

    private var timeString: String {
        let mins = timeRemaining / 60
        let secs = timeRemaining % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
