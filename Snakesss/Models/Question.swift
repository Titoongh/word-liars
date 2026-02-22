import Foundation

struct Question: Codable, Identifiable {
    let id: String
    let question: String
    let choices: Choices
    let answer: String
    let funFact: String?
    let category: String?
    /// Difficulty level: "easy", "medium", or "hard". Defaults to "medium" for backward compatibility.
    let difficulty: String

    struct Choices: Codable {
        let a: String
        let b: String
        let c: String
    }

    init(
        id: String,
        question: String,
        choices: Choices,
        answer: String,
        funFact: String?,
        category: String?,
        difficulty: String = "medium"
    ) {
        self.id = id
        self.question = question
        self.choices = choices
        self.answer = answer
        self.funFact = funFact
        self.category = category
        self.difficulty = difficulty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        question = try container.decode(String.self, forKey: .question)
        choices = try container.decode(Choices.self, forKey: .choices)
        answer = try container.decode(String.self, forKey: .answer)
        funFact = try container.decodeIfPresent(String.self, forKey: .funFact)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        difficulty = (try container.decodeIfPresent(String.self, forKey: .difficulty)) ?? "medium"
    }
}
