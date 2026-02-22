import SwiftUI
import SwiftData

@main
struct SnakesssApp: App {
    @AppStorage("snakesss.hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            HomeView()
                .fullScreenCover(isPresented: .constant(!hasSeenOnboarding)) {
                    OnboardingView {
                        hasSeenOnboarding = true
                    }
                }
        }
        .modelContainer(for: GameRecord.self)
    }
}
