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

    /// Questions filtered by SettingsManager.enabledCategories.
    /// Questions without a category are always included.
    private func filteredPool() -> [Question] {
        let enabled = SettingsManager.shared.enabledCategories
        return allQuestions.filter { q in
            guard let cat = q.category else { return true }
            return enabled.contains(cat)
        }
    }

    func getQuestion() -> Question? {
        let pool = filteredPool()
        let available = pool.filter { !usedQuestionIDs.contains($0.id) }
        if available.isEmpty {
            // Reset used IDs within the filtered pool only
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
