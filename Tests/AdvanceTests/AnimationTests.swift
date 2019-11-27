import XCTest
@testable import Advance


class AnimationTests: XCTestCase {
    
    let animation = Animation(from: Double(0.0), to: Double(10.0), duration: 2.0, timingFunction: .linear)

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
            let current = interpolate(from: a.from.animatableData, to: a.to.animatableData, alpha: elapsed/a.duration)
            XCTAssert(a.value.animatableData == current)
        }
        XCTAssert(a.value == a.to)
    }
    
    static var allTests = [
        ("testDuration", testDuration),
        ("testInterpolation", testInterpolation),
    ]

}
