import XCTest
@testable import Snakesss

final class RoleServiceTests: XCTestCase {

    let service = RoleService()

    func testFourPlayersDistribution() {
        let roles = service.assignRoles(playerCount: 4)
        XCTAssertEqual(roles.count, 4)
        XCTAssertEqual(roles.filter { $0 == .human }.count, 1)
        XCTAssertEqual(roles.filter { $0 == .snake }.count, 2)
        XCTAssertEqual(roles.filter { $0 == .mongoose }.count, 1)
    }

    func testFivePlayersDistribution() {
        let roles = service.assignRoles(playerCount: 5)
        XCTAssertEqual(roles.count, 5)
        XCTAssertEqual(roles.filter { $0 == .human }.count, 2)
        XCTAssertEqual(roles.filter { $0 == .snake }.count, 2)
        XCTAssertEqual(roles.filter { $0 == .mongoose }.count, 1)
    }

    func testSixPlayersDistribution() {
        let roles = service.assignRoles(playerCount: 6)
        XCTAssertEqual(roles.count, 6)
        XCTAssertEqual(roles.filter { $0 == .human }.count, 2)
        XCTAssertEqual(roles.filter { $0 == .snake }.count, 3)
        XCTAssertEqual(roles.filter { $0 == .mongoose }.count, 1)
    }

    func testSevenPlayersDistribution() {
        let roles = service.assignRoles(playerCount: 7)
        XCTAssertEqual(roles.count, 7)
        XCTAssertEqual(roles.filter { $0 == .human }.count, 3)
        XCTAssertEqual(roles.filter { $0 == .snake }.count, 3)
        XCTAssertEqual(roles.filter { $0 == .mongoose }.count, 1)
    }

    func testEightPlayersDistribution() {
        let roles = service.assignRoles(playerCount: 8)
        XCTAssertEqual(roles.count, 8)
        XCTAssertEqual(roles.filter { $0 == .human }.count, 3)
        XCTAssertEqual(roles.filter { $0 == .snake }.count, 4)
        XCTAssertEqual(roles.filter { $0 == .mongoose }.count, 1)
    }

    func testAlwaysExactlyOneMongoose() {
        for playerCount in 4...8 {
            let roles = service.assignRoles(playerCount: playerCount)
            XCTAssertEqual(
                roles.filter { $0 == .mongoose }.count,
                1,
                "Expected exactly 1 mongoose for \(playerCount) players"
            )
        }
    }

    func testArrayLengthMatchesPlayerCount() {
        for playerCount in 4...8 {
            let roles = service.assignRoles(playerCount: playerCount)
            XCTAssertEqual(roles.count, playerCount, "Role count mismatch for \(playerCount) players")
        }
    }
}
