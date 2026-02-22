import Foundation

@MainActor
final class QuestionService {
    private var allQuestions: [Question]
    private(set) var usedQuestionIDs: Set<String>

    private static let usedIDsKey = "usedQuestionIDs"

    init() {
        self.allQuestions = Self.loadFromBundle()
        let saved = UserDefaults.standard.stringArray(forKey: Self.usedIDsKey) ?? []
        self.usedQuestionIDs = Set(saved)
    }

    init(questions: [Question]) {
        self.allQuestions = questions
        self.usedQuestionIDs = []
    }

    private static func loadFromBundle() -> [Question] {
        let resource = localeQuestionsResource()
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            return []
        }
        return questions
    }

    /// Returns the questions JSON file name appropriate for the current locale.
    /// Falls back to French questions for any non-English locale.
    private static func localeQuestionsResource() -> String {
        let preferred = Bundle.main.preferredLocalizations.first ?? "fr"
        return preferred.hasPrefix("en") ? "questions_en" : "questions"
    }

    var remainingCount: Int {
        filteredPool().filter { !usedQuestionIDs.contains($0.id) }.count
    }

    /// Questions filtered by both category and difficulty settings.
    /// Questions without a category are always included for category filter.
    /// If the difficulty-filtered pool is too small (< roundCount), falls back to mixed selection.
    private func filteredPool() -> [Question] {
        let settings = SettingsManager.shared
        let enabled = settings.enabledCategories
        let difficulty = settings.difficulty

        // Apply category filter first
        let categoryFiltered = allQuestions.filter { q in
            guard let cat = q.category else { return true }
            return enabled.contains(cat)
        }

        // Apply difficulty filter
        return applyDifficultyFilter(categoryFiltered, difficulty: difficulty, roundCount: settings.roundCount)
    }

    /// Applies difficulty filtering with fallback to mixed if pool is too small.
    private func applyDifficultyFilter(_ questions: [Question], difficulty: String, roundCount: Int) -> [Question] {
        if difficulty == "mixed" {
            return questions
        }

        let filtered = questions.filter { $0.difficulty == difficulty }

        // Fall back to all questions if filtered pool is too small
        if filtered.count < roundCount {
            return questions
        }

        return filtered
    }

    func getQuestion() -> Question? {
        let pool = filteredPool()
        let difficulty = SettingsManager.shared.difficulty

        if difficulty == "mixed" {
            return pickMixed(from: pool)
        }

        let available = pool.filter { !usedQuestionIDs.contains($0.id) }
        if available.isEmpty {
            let poolIDs = Set(pool.map(\.id))
            usedQuestionIDs.subtract(poolIDs)
            persistUsedIDs()
            if let question = pool.randomElement() {
                markUsed(question.id)
                return question
            }
            return nil
        }
        let question = available.randomElement()!
        markUsed(question.id)
        return question
    }

    /// Weighted random selection for mixed mode: 30% easy, 50% medium, 20% hard.
    private func pickMixed(from pool: [Question]) -> Question? {
        let available = pool.filter { !usedQuestionIDs.contains($0.id) }
        let source = available.isEmpty ? pool : available

        if available.isEmpty {
            let poolIDs = Set(pool.map(\.id))
            usedQuestionIDs.subtract(poolIDs)
            persistUsedIDs()
        }

        // Try weighted selection
        let roll = Int.random(in: 0..<100)
        let targetDifficulty: String
        if roll < 30 {
            targetDifficulty = "easy"
        } else if roll < 80 {
            targetDifficulty = "medium"
        } else {
            targetDifficulty = "hard"
        }

        let weighted = source.filter { $0.difficulty == targetDifficulty }
        let question = (weighted.isEmpty ? source : weighted).randomElement()!
        markUsed(question.id)
        return question
    }

    func markUsed(_ id: String) {
        usedQuestionIDs.insert(id)
        persistUsedIDs()
    }

    func resetPool() {
        usedQuestionIDs.removeAll()
        persistUsedIDs()
    }

    private func persistUsedIDs() {
        UserDefaults.standard.set(Array(usedQuestionIDs), forKey: Self.usedIDsKey)
    }
}
