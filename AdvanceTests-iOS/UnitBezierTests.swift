import XCTest
@testable import Advance


class UnitBezierTests : XCTestCase {
    let eps: Scalar = 0.001
    
    func testLinear() {
        let values: [Scalar] = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
        let b = UnitBezier(p1x: 0.0, p1y: 0.0, p2x: 1.0, p2y: 1.0)
        
        for i in 0..<values.count {
            let v = b.solve(Scalar(i) / Scalar(values.count - 1), epsilon: eps)
            let expected = values[i]
            XCTAssertEqual(v, expected, accuracy: eps)
        }
    }
    
    func testCurve() {
        let values: [Scalar] = [0, 0.01965137076241203, 0.08141362197218191, 0.1871705774437696, 0.331832067207064, 0.5, 0.668167932792936, 0.8128294225562304, 0.9185863780278181, 0.980348629237588, 1]
        let b = UnitBezier(p1x: 0.42, p1y: 0.0, p2x: 0.58, p2y: 1.0) // ease in/out
        
        for i in 0..<values.count {
            let v = b.solve(Scalar(i) / Scalar(values.count - 1), epsilon: eps)
            let expected = values[i]
            XCTAssertEqual(v, expected, accuracy: eps)
        }
    }
}
