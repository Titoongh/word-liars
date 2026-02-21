import Foundation

final class RoleService {
    static let distributionTable: [Int: (humans: Int, snakes: Int, mongoose: Int)] = [
        4: (humans: 1, snakes: 2, mongoose: 1),
        5: (humans: 2, snakes: 2, mongoose: 1),
        6: (humans: 2, snakes: 3, mongoose: 1),
        7: (humans: 3, snakes: 3, mongoose: 1),
        8: (humans: 3, snakes: 4, mongoose: 1)
    ]

    func assignRoles(playerCount: Int) -> [Role] {
        guard let distribution = Self.distributionTable[playerCount] else {
            return []
        }
        var roles: [Role] = []
        roles += Array(repeating: .human, count: distribution.humans)
        roles += Array(repeating: .snake, count: distribution.snakes)
        roles += Array(repeating: .mongoose, count: distribution.mongoose)
        return roles.shuffled()
    }
}
