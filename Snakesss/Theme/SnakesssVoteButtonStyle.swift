import SwiftUI

// MARK: - Vote Button Style

/// Voting screen button (A/B/C columns).
/// - Shape: radiusXl (20pt)
/// - Fill: bgCard
/// - Border: 2pt borderSubtle (default) / accentPrimary (selected)
/// - Layout: 48pt letter (Black, accentPrimary) centered + short text below
/// - Selected: border accentPrimary + 16px glow + scale 1.02
struct SnakesssVoteButtonStyle: ButtonStyle {
    let isSelected: Bool

    init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: SnakesssRadius.radiusXl)
                    .fill(SnakesssTheme.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: SnakesssRadius.radiusXl)
                            .strokeBorder(
                                isSelected
                                    ? SnakesssTheme.accentPrimary
                                    : SnakesssTheme.borderSubtle,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: isSelected ? SnakesssTheme.accentGlow : .clear,
                radius: 16,
                x: 0,
                y: 0
            )
            .scaleEffect(isSelected ? 1.02 : (configuration.isPressed ? 0.97 : 1.0))
            .animation(SnakesssAnimation.bouncy, value: isSelected)
            .animation(SnakesssAnimation.bouncy, value: configuration.isPressed)
    }
}

// MARK: - Vote Button Content View

/// Wrapper view with the letter + answer label layout for vote buttons.
/// Use inside a Button with SnakesssVoteButtonStyle.
struct VoteButtonContent: View {
    let letter: String
    let answer: String

    var body: some View {
        VStack(spacing: SnakesssSpacing.spacing1) {
            Text(letter)
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(SnakesssTheme.accentPrimary)

            Text(answer)
                .font(SnakesssTypography.caption)
                .foregroundStyle(SnakesssTheme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SnakesssSpacing.spacing4)
        .padding(.horizontal, SnakesssSpacing.spacing2)
    }
}

// MARK: - Preview

#Preview("Vote Buttons") {
    HStack(spacing: 12) {
        Button {
        } label: {
            VoteButtonContent(letter: "A", answer: "Switzerland")
        }
        .buttonStyle(SnakesssVoteButtonStyle(isSelected: true))

        Button {
        } label: {
            VoteButtonContent(letter: "B", answer: "Belgium")
        }
        .buttonStyle(SnakesssVoteButtonStyle())

        Button {
        } label: {
            VoteButtonContent(letter: "C", answer: "Germany")
        }
        .buttonStyle(SnakesssVoteButtonStyle())
    }
    .padding(28)
    .background(Color(hex: "#0A1A10"))
}
