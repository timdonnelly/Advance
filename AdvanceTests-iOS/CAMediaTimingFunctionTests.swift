import XCTest
@testable import Advance


class CAMediaTimingFunctionTests : XCTestCase {
    func testConversion() {
        let p1x: Float = 0.42
        let p1y: Float = 0.0
        let p2x: Float = 0.58
        let p2y: Float = 1.0
        
        let timingFunction = CAMediaTimingFunction(controlPoints: p1x, p1y, p2x, p2y)
        let bezier = timingFunction.unitBezier
        
        XCTAssertEqual(bezier.first.x, Scalar(p1x))
        XCTAssertEqual(bezier.first.y, Scalar(p1y))
        XCTAssertEqual(bezier.second.x, Scalar(p2x))
        XCTAssertEqual(bezier.second.y, Scalar(p2y))
    }
}
