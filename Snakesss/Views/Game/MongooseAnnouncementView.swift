import SwiftUI

// MARK: - MongooseAnnouncementView

/// Publicly announces the Truth Mongoose's identity to all players.
struct MongooseAnnouncementView: View {
    let mongooseName: String
    let onContinue: () -> Void

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            SnakesssTheme.bgBase.ignoresSafeArea()
            SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: SnakesssSpacing.spacing8) {
                Spacer()

                // Mongoose emoji
                Text("🦦")
                    .font(.system(size: 100))
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .shadow(color: SnakesssTheme.mongooseColor.opacity(0.4), radius: 30)

                // Announcement text
                VStack(spacing: SnakesssSpacing.spacing3) {
                    Text("The Truth Mongoose is...")
                        .font(SnakesssTypography.label)
                        .foregroundStyle(SnakesssTheme.textSecondary)

                    Text(mongooseName)
                        .font(SnakesssTypography.title)
                        .foregroundStyle(SnakesssTheme.mongooseColor)
                        .shadow(color: SnakesssTheme.mongooseColor.opacity(0.30), radius: 12)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                }

                Text("Everyone can see who the Mongoose is.\nSnakes — don't let them find the truth.")
                    .font(SnakesssTypography.caption)
                    .foregroundStyle(SnakesssTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SnakesssSpacing.spacing8)

                Spacer()

                Button("Show the Question") {
                    onContinue()
                }
                .buttonStyle(SnakesssPrimaryButtonStyle())
                .padding(.horizontal, SnakesssSpacing.screenPadding)
                .padding(.bottom, SnakesssSpacing.spacing12)
            }
        }
        .onAppear {
            withAnimation(SnakesssAnimation.celebration) {
                isAnimating = true
            }
        }
    }
}
