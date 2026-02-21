import SwiftUI
import SwiftData

@main
struct SnakesssApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: GameRecord.self)
    }
}
