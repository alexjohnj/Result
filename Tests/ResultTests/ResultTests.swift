import XCTest
@testable import Result

enum TestError: Error {
    case GenericError
    case AnotherGenericError
}

class ResultTests: XCTestCase {
    func testResultOKEquality() {
        let resultOne = Result<Int>.ok(23)
        let resultTwo = Result<Int>.ok(23)
        let resultThree = Result<Int>.ok(12)
        XCTAssertTrue(resultOne == resultTwo)
        XCTAssertFalse(resultOne == resultThree)
    }

    func testResultFailEquality() {
        let resultOne = Result<Int>.fail(TestError.GenericError)
        let resultTwo = Result<Int>.ok(12)
        let resultThree = Result<Int>.fail(TestError.AnotherGenericError)

        XCTAssertFalse(resultOne == resultTwo)
        XCTAssertFalse(resultOne == resultThree)
    }
}
