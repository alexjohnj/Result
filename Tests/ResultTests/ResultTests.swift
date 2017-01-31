import XCTest
@testable import Result

enum TestError: Error {
    case GenericError
}

func helperThrowingFunction(shouldThrow: Bool) throws -> Int {
    if shouldThrow {
        throw(TestError.GenericError)
    } else {
        return 23
    }
}

class ResultTests: XCTestCase {
    func testGetResultOptionalValue() {
        let testResultNotNil = Result(val: 23)
        XCTAssertNotNil(testResultNotNil.value)
        XCTAssertEqual(testResultNotNil.value, 23)

        let testResultNil: Result<Int> = Result(error: TestError.GenericError)
        XCTAssertNil(testResultNil.value)
    }

    func testInitResultFromNilOptional() {
        let testValue: Int? = nil
        let testResult = Result(testValue, error: TestError.GenericError)

        XCTAssertNil(testResult.value)
    }

    func testInitResultFromNonNilOptional() {
        let testValue: Int? = 12
        let testResult = Result(testValue, error: TestError.GenericError)

        XCTAssertNotNil(testResult.value)
    }

    func testInitFromThrowingFunction() {
        let testResult = Result(try: { try helperThrowingFunction(shouldThrow: true) })
        XCTAssertNil(testResult.value)
    }

    func testInitFromNonThrowingFunction() {
        let testResult = Result(try: { try helperThrowingFunction(shouldThrow: false) })
        XCTAssertNotNil(testResult.value)
    }

    func testInitFromThrowingAutoclosure() {
        let testResult = Result(try helperThrowingFunction(shouldThrow: true))
        XCTAssertNil(testResult.value)
    }

    func testInitFromNonThrowingAutoclosure() {
        let testResult = Result(try helperThrowingFunction(shouldThrow: false))
        XCTAssertNotNil(testResult.value)
    }

    func testDematerializeThrows() {
        let testResult: Result<Int> = Result(nil, error: TestError.GenericError)
        XCTAssertThrowsError(try testResult.dematerialize()) { error in
            guard case TestError.GenericError = error else {
                return XCTFail()
            }
        }
    }

    func testDematerializeNonNilDoesntThrow() {
        let testResult = Result(32, error: TestError.GenericError)
        let unwrappedValue = try? testResult.dematerialize()
        XCTAssertNotNil(unwrappedValue)
        XCTAssertEqual(unwrappedValue, 32)
    }

    func testMapOKResult() {
        let testResult = Result(val: 32)
        let id = { (d: Int) -> Int in d }

        let mappedResult = testResult.map(id)
        XCTAssertEqual(mappedResult.value, testResult.value)
    }

    func testMapFailResult() {
        let testResult: Result<Int> = Result(error: TestError.GenericError)
        let id = { (d: Int) -> Int in d }

        let mappedResult = testResult.map(id)
        XCTAssertNil(mappedResult.value)
    }

    func testFlatMapOKResult() {
        let testResult = Result(val: 23)
        let id = { (d: Int) -> Result<Int> in .ok(d) }

        let mappedResult = testResult.flatMap(id)
        XCTAssertEqual(mappedResult.value, testResult.value)
    }

    func testFlatMapFailResult() {
        let testResult: Result<Int> = Result(error: TestError.GenericError)
        let id = { (d: Int) -> Result<Int> in .ok(d) }

        let mappedValue = testResult.flatMap(id)
        XCTAssertNil(mappedValue.value)
    }
}
