import Foundation

/// Shared coordinator for cross-view navigation events.
/// Injected at HomeView level so any descendant can trigger a "return to home" dismissal.
@Observable
@MainActor
final class GameNavigationCoordinator {
    var shouldReturnHome = false
}
