import SwiftUI

// MARK: - HomeView

/// Landing screen. Entry point for new games.
struct HomeView: View {
    @State private var isSnakePulsing = false
    @State private var showingHistory = false
    @State private var coordinator = GameNavigationCoordinator()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var displayFontSize: CGFloat = 52

    var body: some View {
        NavigationStack {
            ZStack {
                SnakesssTheme.bgBase.ignoresSafeArea()
                    .scaleTexture()
                SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

                VStack(spacing: 0) {
                    Spacer()

                    // Logo section
                    VStack(spacing: SnakesssSpacing.spacing4) {
                        // Snake emoji with breathing pulse (1.0 ↔ 0.97, 2s loop)
                        Text("🐍")
                            .font(.system(size: 80))
                            .shadow(color: SnakesssTheme.accentPrimary.opacity(0.4), radius: 24)
                            .scaleEffect(isSnakePulsing ? 0.97 : 1.0)
                            .animation(
                                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                value: isSnakePulsing
                            )

                        Text("Snakesss")
                            .font(.system(size: displayFontSize, weight: .black, design: .rounded))
                            .foregroundStyle(SnakesssTheme.accentPrimary)
                            .accentGlow()

                        Text("TRUST NOBODY")
                            .microStyle(color: SnakesssTheme.textMuted)
                    }

                    Spacer()

                    // Role badge pills
                    HStack(spacing: SnakesssSpacing.spacing3) {
                        RoleBadgeView(role: .human)
                        RoleBadgeView(role: .snake)
                        RoleBadgeView(role: .mongoose)
                    }
                    .padding(.bottom, SnakesssSpacing.spacing8)

                    // Action buttons
                    VStack(spacing: SnakesssSpacing.spacing3) {
                        NavigationLink(destination: PlayerSetupView()) {
                            Text("New Game")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SnakesssPrimaryButtonStyle())

                        Button {
                            showingHistory = true
                        } label: {
                            Text("Game History")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SnakesssSecondaryButtonStyle())
                    }
                    .padding(.horizontal, SnakesssSpacing.screenPadding)

                    // Studio stamp
                    Text("GOBC GAMES")
                        .microStyle(color: SnakesssTheme.textMuted.opacity(0.5))
                        .padding(.top, SnakesssSpacing.spacing6)
                        .padding(.bottom, SnakesssSpacing.spacing12)
                }
            }
            .navigationBarHidden(true)
            .onAppear { if !reduceMotion { isSnakePulsing = true } }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
        }
        .environment(coordinator)
    }
}

#Preview {
    HomeView()
}
