import SwiftUI

// MARK: - QuestionView

/// Center-table question display. Large text for easy group reading.
/// Shows question + A/B/C choices. Snakes already know the answer; humans debate.
struct QuestionView: View {
    let question: Question
    let roundNumber: Int
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                // Round badge
                Text("Round \(roundNumber) — Question")
                    .microStyle(color: SnakesssTheme.textMuted)
                    .padding(.top, SnakesssSpacing.spacing8)

                Spacer()

                // Question card
                VStack(spacing: SnakesssSpacing.spacing6) {
                    Text(question.question)
                        .font(SnakesssTypography.question)
                        .foregroundStyle(SnakesssTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    // Answer choices
                    VStack(spacing: SnakesssSpacing.spacing3) {
                        answerRow(letter: "A", text: question.choices.a)
                        answerRow(letter: "B", text: question.choices.b)
                        answerRow(letter: "C", text: question.choices.c)
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
                .padding(.horizontal, SnakesssSpacing.screenPadding)

                Spacer()

                // Instructions
                Text("Discuss the question, then Snakes will secretly see the answer.")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SnakesssSpacing.spacing8)
                    .padding(.bottom, SnakesssSpacing.spacing4)

                Button("Snakes — Close Your Eyes") {
                    onContinue()
                }
                .buttonStyle(SnakesssPrimaryButtonStyle())
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .padding(.bottom, SnakesssSpacing.spacing12)
            }
        }
    }

    private func answerRow(letter: String, text: String) -> some View {
        HStack(spacing: SnakesssSpacing.spacing3) {
            // Letter badge
            ZStack {
                Circle()
                    .fill(SnakesssTheme.accentPrimary.opacity(0.12))
                    .overlay(Circle().strokeBorder(SnakesssTheme.borderActive, lineWidth: 1))
                    .frame(width: 36, height: 36)
                Text(letter)
                    .font(SnakesssTypography.micro)
                    .foregroundStyle(SnakesssTheme.accentPrimary)
            }

            Text(text)
                .font(SnakesssTypography.answer)
                .foregroundStyle(SnakesssTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal, SnakesssSpacing.spacing4)
        .padding(.vertical, SnakesssSpacing.spacing3)
        .background(
            RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                .fill(SnakesssTheme.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: SnakesssRadius.radiusLg)
                        .strokeBorder(SnakesssTheme.borderSubtle, lineWidth: 1)
                )
        )
    }
}
