import SwiftUI

// MARK: - HomeView

/// Landing screen. Entry point for new games.
struct HomeView: View {
    @State private var navigateToSetup = false

    var body: some View {
        NavigationStack {
            ZStack {
                SnakesssTheme.bgBase.ignoresSafeArea()
                SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

                VStack(spacing: 0) {
                    Spacer()

                    // Logo
                    VStack(spacing: SnakesssSpacing.spacing4) {
                        Text("🐍")
                            .font(.system(size: 80))
                            .shadow(color: SnakesssTheme.accentPrimary.opacity(0.4), radius: 24)

                        Text("Snakesss")
                            .font(SnakesssTypography.display)
                            .foregroundStyle(SnakesssTheme.accentPrimary)
                            .accentGlow()

                        Text("TRUST NOBODY")
                            .microStyle(color: SnakesssTheme.textMuted)
                    }

                    Spacer()

                    // Buttons
                    VStack(spacing: SnakesssSpacing.spacing3) {
                        NavigationLink(destination: PlayerSetupView()) {
                            Text("New Game")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SnakesssPrimaryButtonStyle())

                        Text("4–8 players · Pass-and-play · ~30 min")
                            .font(SnakesssTypography.caption)
                            .foregroundStyle(SnakesssTheme.textMuted)
                    }
                    .padding(.horizontal, SnakesssSpacing.screenPadding)
                    .padding(.bottom, SnakesssSpacing.spacing12)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
