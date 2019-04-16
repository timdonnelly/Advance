import XCTest
@testable import Advance


class BasicAnimationTests: XCTestCase {
    
    let animation = TimedAnimation(from: Double(0.0), to: Double(10.0), duration: 2.0, timingFunction: LinearTimingFunction())

    func testDuration() {
        var a = animation
        var elapsed: Double = 0
        while true {
            elapsed += 0.1
            a.advance(by: 0.1)
            guard elapsed < a.duration else { break }
            XCTAssert(a.isFinished == false)
        }
        XCTAssert(a.isFinished == true)
    }
    
    func testInterpolation() {
        var a = animation
        var elapsed: Double = 0
        while true {
            elapsed += 0.1
            a.advance(by: 0.1)
            guard elapsed < a.duration else { break }
            let current = a.from.interpolated(to: a.to, alpha: elapsed/a.duration)
            XCTAssert(a.value == current)
        }
        XCTAssert(a.value == a.to)
    }

}
