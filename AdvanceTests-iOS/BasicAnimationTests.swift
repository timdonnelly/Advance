import XCTest
@testable import Advance


class BasicAnimationTests: XCTestCase {
    
    let animation = BasicAnimation(from: Scalar(0.0), to: Scalar(10.0), duration: 2.0, timingFunction: LinearTimingFunction())

    func testDuration() {
        var a = animation
        var elapsed: Double = 0
        while true {
            elapsed += 0.1
            a.advance(by: 0.1)
            guard elapsed < a.duration else { break }
            XCTAssert(a.finished == false)
        }
        XCTAssert(a.finished == true)
    }
    
    func testInterpolation() {
        var a = animation
        var elapsed: Double = 0
        while true {
            elapsed += 0.1
            a.advance(by: 0.1)
            guard elapsed < a.duration else { break }
            let current = a.from.interpolatedTo(a.to, alpha: elapsed/a.duration)
            XCTAssert(a.value == current)
        }
        XCTAssert(a.value == a.to)
    }

}
