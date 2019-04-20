import XCTest
@testable import Advance


class TimingFunctionTests : XCTestCase {
    
    func testConversion() {
        let p1x: Float = 0.42
        let p1y: Float = 0.0
        let p2x: Float = 0.58
        let p2y: Float = 1.0
        
        let caTimingFunction = CAMediaTimingFunction(controlPoints: p1x, p1y, p2x, p2y)
        let function = TimingFunction(coreAnimationTimingFunction: caTimingFunction)
        
        switch function {
        case .linear:
            XCTFail()
        case .bezier(let bezier):
            XCTAssertEqual(bezier.first.x, Double(p1x))
            XCTAssertEqual(bezier.first.y, Double(p1y))
            XCTAssertEqual(bezier.second.x, Double(p2x))
            XCTAssertEqual(bezier.second.y, Double(p2y))
        }
        

    }
    
    static var allTests = [
        ("testConversion", testConversion),
    ]
}
