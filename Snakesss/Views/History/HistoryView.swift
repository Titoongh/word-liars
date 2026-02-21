import SwiftUI
import SwiftData

// MARK: - HistoryView

/// Displays a reverse-chronological list of past games stored in SwiftData.
/// Accessible from HomeView via a sheet presentation.
struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameRecord.date, order: .reverse) private var games: [GameRecord]

    var body: some View {
        NavigationStack {
            ZStack {
                SnakesssTheme.bgBase.ignoresSafeArea()
                    .scaleTexture() // M1

                Group {
                    if games.isEmpty {
                        emptyState
                    } else {
                        gameList
                    }
                }
            }
            .navigationTitle("Game History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(SnakesssTheme.bgSurface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(SnakesssTypography.caption)
                        .foregroundStyle(SnakesssTheme.accentPrimary)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SnakesssSpacing.spacing5) {
            Text("🎮")
                .font(.system(size: 72))

            VStack(spacing: SnakesssSpacing.spacing2) {
                Text("No games played yet")
                    .font(SnakesssTypography.headline)
                    .foregroundStyle(SnakesssTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Start your first game!")
                    .font(SnakesssTypography.body)
                    .foregroundStyle(SnakesssTheme.textSecondary)
            }
        }
        .padding(SnakesssSpacing.screenPadding)
    }

    // MARK: - Game List

    private var gameList: some View {
        ScrollView {
            LazyVStack(spacing: SnakesssSpacing.spacing3) {
                ForEach(games) { game in
                    HistoryRowView(game: game)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(game)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, SnakesssSpacing.screenPadding)
            .padding(.vertical, SnakesssSpacing.spacing4)
        }
    }
}

// MARK: - HistoryRowView

private struct HistoryRowView: View {
    let game: GameRecord

    private var winnerDisplay: String {
        guard !game.winnerNames.isEmpty else { return "No winner" }
        return game.winnerNames.joined(separator: " & ")
    }

    private var winnerScore: Int? {
        guard let winnerName = game.winnerNames.first,
              let winnerIndex = game.playerNames.firstIndex(of: winnerName),
              winnerIndex < game.finalScores.count else { return nil }
        return game.finalScores[winnerIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SnakesssSpacing.spacing3) {
            // Header: date + round count
            HStack {
                Text(game.date, style: .date)
                    .microStyle(color: SnakesssTheme.textMuted)

                Spacer()

                Text("\(game.roundCount) rounds · \(game.playerNames.count) players")
                    .microStyle(color: SnakesssTheme.textMuted)
            }

            // Winner row
            HStack(spacing: SnakesssSpacing.spacing2) {
                Text("🏆")
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 2) {
                    Text(winnerDisplay)
                        .font(SnakesssTypography.bodyLarge)
                        .foregroundStyle(SnakesssTheme.truthGold)
                        .goldGlow()

                    if let score = winnerScore {
                        Text("\(score) pts")
                            .font(SnakesssTypography.caption)
                            .foregroundStyle(SnakesssTheme.textSecondary)
                    }
                }

                Spacer()
            }

            // All player names
            Text(game.playerNames.joined(separator: " · "))
                .font(SnakesssTypography.caption)
                .foregroundStyle(SnakesssTheme.textSecondary)
                .lineLimit(2)
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
    }
}

// MARK: - Previews

#Preview("Empty State") {
    HistoryView()
        .modelContainer(for: GameRecord.self, inMemory: true)
}

#Preview("With Games") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GameRecord.self, configurations: config)
    let ctx = container.mainContext

    ctx.insert(GameRecord(
        date: Date(),
        playerNames: ["Alice", "Bob", "Charlie", "Diana"],
        finalScores: [42, 38, 25, 19],
        winnerNames: ["Alice"],
        roundCount: 6
    ))
    ctx.insert(GameRecord(
        date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        playerNames: ["Eve", "Frank", "Grace", "Hank", "Ivy"],
        finalScores: [30, 30, 18, 12, 8],
        winnerNames: ["Eve", "Frank"],
        roundCount: 6
    ))
    ctx.insert(GameRecord(
        date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        playerNames: ["Jake", "Kai"],
        finalScores: [15, 22],
        winnerNames: ["Kai"],
        roundCount: 4
    ))

    return HistoryView()
        .modelContainer(container)
}
