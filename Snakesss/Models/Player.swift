import Foundation

struct Player: Identifiable {
    let id: UUID
    var name: String
    var role: Role?
    var totalScore: Int
    var currentVote: Vote?
}
