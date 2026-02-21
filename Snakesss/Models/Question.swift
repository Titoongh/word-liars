import Foundation

struct Question: Codable, Identifiable {
    let id: String
    let question: String
    let choices: Choices
    let answer: String
    let funFact: String?
    let category: String?

    struct Choices: Codable {
        let a: String
        let b: String
        let c: String
    }
}
