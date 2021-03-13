import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(indico_fetcherTests.allTests),
    ]
}
#endif
