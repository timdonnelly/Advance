import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TimingFunctionTests.allTests),
        testCase(UnitBezierTests.allTests),
        testCase(DisplayLinkTests.allTests),
        testCase(AnimationTests.allTests),
        testCase(VectorConvenienceTests.allTests),
    ]
}
#endif
