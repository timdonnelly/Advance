import XCTest
@testable import Advance


class CAMediaTimingFunctionTests : XCTestCase {
    func testConversion() {
        let p1x: Float = 0.42
        let p1y: Float = 0.0
        let p2x: Float = 0.58
        let p2y: Float = 1.0
        
        let ca = CAMediaTimingFunction(controlPoints: p1x, p1y, p2x, p2y)
        let ub = ca.unitBezier
        
        XCTAssertEqual(ub.p1x, Scalar(p1x))
        XCTAssertEqual(ub.p1y, Scalar(p1y))
        XCTAssertEqual(ub.p2x, Scalar(p2x))
        XCTAssertEqual(ub.p2y, Scalar(p2y))
    }
}
