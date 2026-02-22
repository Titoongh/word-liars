import SwiftUI

// MARK: - HomeView

/// Landing screen. Entry point for new games.
struct HomeView: View {
    @State private var showingHistory = false
    @State private var showingSettings = false
    @State private var showingHowToPlay = false
    @State private var coordinator = GameNavigationCoordinator()
    @ScaledMetric(relativeTo: .largeTitle) private var displayFontSize: CGFloat = 52

    var body: some View {
        NavigationStack {
            ZStack {
                SnakesssTheme.bgBase.ignoresSafeArea()
                    .scaleTexture()
                SnakesssTheme.greenRadialOverlay.ignoresSafeArea().allowsHitTesting(false)

                // Gear icon — top-right corner
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            SnakesssHaptic.light()
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(SnakesssTheme.textMuted)
                        }
                        .accessibilityLabel(Text("home.settings.accessibility"))
                        .padding(.top, SnakesssSpacing.spacing6)
                        .padding(.trailing, SnakesssSpacing.screenPadding)
                    }
                    Spacer()
                }

                VStack(spacing: 0) {
                    Spacer()

                    // Logo section
                    VStack(spacing: SnakesssSpacing.spacing4) {
                        Text("🐍")
                            .font(.system(size: 80))
                            .shadow(color: SnakesssTheme.accentPrimary.opacity(0.4), radius: 24)

                        Text("Snakesss")
                            .font(.system(size: displayFontSize, weight: .black, design: .rounded))
                            .foregroundStyle(SnakesssTheme.accentPrimary)
                            .accentGlow()

                        Text("home.tagline")
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
                            Text("home.newGame.button")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SnakesssPrimaryButtonStyle())

                        Button {
                            showingHistory = true
                        } label: {
                            Text("home.gameHistory.button")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SnakesssSecondaryButtonStyle())

                        Button {
                            SnakesssHaptic.light()
                            showingHowToPlay = true
                        } label: {
                            Label(
                                title: { Text("home.howToPlay.button") },
                                icon: { Image(systemName: "questionmark.circle") }
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SnakesssSecondaryButtonStyle())
                        .accessibilityLabel(Text("home.howToPlay.accessibility"))
                    }
                    .padding(.horizontal, SnakesssSpacing.screenPadding)

                    // Studio stamp
                    Text("home.studioStamp")
                        .microStyle(color: SnakesssTheme.textMuted.opacity(0.5))
                        .padding(.top, SnakesssSpacing.spacing6)
                        .padding(.bottom, SnakesssSpacing.spacing12)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .presentationBackground(SnakesssTheme.bgBase)
            }
            .sheet(isPresented: $showingHowToPlay) {
                RulesSheetView()
            }
        }
        .environment(coordinator)
    }
}

#Preview {
    HomeView()
}
