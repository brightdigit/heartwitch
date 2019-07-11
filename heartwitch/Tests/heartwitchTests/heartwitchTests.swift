import XCTest
@testable import heartwitch

final class heartwitchTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(heartwitch().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
