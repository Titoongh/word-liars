import XCTest
@testable import Snakesss

@MainActor
final class QuestionServiceTests: XCTestCase {

    private func makeSampleQuestions(count: Int) -> [Question] {
        (1...count).map { i in
            Question(
                id: String(format: "q%03d", i),
                question: "Question \(i)?",
                choices: Question.Choices(a: "Option A", b: "Option B", c: "Option C"),
                answer: "A",
                funFact: nil,
                category: nil
            )
        }
    }

    func testLoadsQuestionsSuccessfully() {
        let questions = makeSampleQuestions(count: 5)
        let service = QuestionService(questions: questions)
        XCTAssertEqual(service.remainingCount, 5)
    }

    func testNoRepeatsWithinTenCalls() {
        let questions = makeSampleQuestions(count: 10)
        let service = QuestionService(questions: questions)
        var seen: Set<String> = []
        for _ in 0..<10 {
            guard let q = service.getQuestion() else {
                XCTFail("getQuestion() returned nil unexpectedly")
                return
            }
            XCTAssertFalse(seen.contains(q.id), "Duplicate question returned: \(q.id)")
            seen.insert(q.id)
        }
        XCTAssertEqual(seen.count, 10)
    }

    func testPoolExhaustionTriggersReset() {
        let questions = makeSampleQuestions(count: 3)
        let service = QuestionService(questions: questions)
        _ = service.getQuestion()
        _ = service.getQuestion()
        _ = service.getQuestion()
        XCTAssertEqual(service.remainingCount, 0)
        let question = service.getQuestion()
        XCTAssertNotNil(question)
    }

    func testMarkUsedReducesRemainingCount() {
        let questions = makeSampleQuestions(count: 5)
        let service = QuestionService(questions: questions)
        service.markUsed("q001")
        XCTAssertEqual(service.remainingCount, 4)
    }

    func testResetPoolRestoresFullCount() {
        let questions = makeSampleQuestions(count: 5)
        let service = QuestionService(questions: questions)
        service.markUsed("q001")
        service.markUsed("q002")
        service.resetPool()
        XCTAssertEqual(service.remainingCount, 5)
    }
}
