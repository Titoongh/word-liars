import Foundation

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
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            return []
        }
        return questions
    }

    var remainingCount: Int {
        allQuestions.filter { !usedQuestionIDs.contains($0.id) }.count
    }

    func getQuestion() -> Question? {
        let available = allQuestions.filter { !usedQuestionIDs.contains($0.id) }
        if available.isEmpty {
            resetPool()
            return allQuestions.randomElement()
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
