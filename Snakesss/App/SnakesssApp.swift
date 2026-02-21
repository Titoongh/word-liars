import SwiftUI
import SwiftData

@main
struct SnakesssApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: GameRecord.self)
    }
}
