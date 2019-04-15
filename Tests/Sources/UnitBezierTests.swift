import XCTest
@testable import Advance


class UnitBezierTests : XCTestCase {
    let eps: Double = 0.001
    
    func testLinear() {
        let values: [Double] = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
        let b = UnitBezier(firstX: 0.0, firstY: 0.0, secondX: 1.0, secondY: 1.0)
        
        for i in 0..<values.count {
            let v = b.solve(x: Double(i) / Double(values.count - 1), epsilon: eps)
            let expected = values[i]
            XCTAssertEqual(v, expected, accuracy: eps)
        }
    }
    
    func testCurve() {
        let values: [Double] = [0, 0.01965137076241203, 0.08141362197218191, 0.1871705774437696, 0.331832067207064, 0.5, 0.668167932792936, 0.8128294225562304, 0.9185863780278181, 0.980348629237588, 1]
        let b = UnitBezier(firstX: 0.42, firstY: 0.0, secondX: 0.58, secondY: 1.0) // ease in/out
        
        for i in 0..<values.count {
            let v = b.solve(x: Double(i) / Double(values.count - 1), epsilon: eps)
            let expected = values[i]
            XCTAssertEqual(v, expected, accuracy: eps)
        }
    }
}
