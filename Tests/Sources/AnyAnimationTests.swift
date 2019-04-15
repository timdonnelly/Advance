import XCTest
@testable import Advance


class AnyAnimationTests : XCTestCase {

    func testFinishing() {
        let basicAnimation = 1.animation(to: 250, duration: 1.0)
        var anyAnimation = AnyAnimation(basicAnimation)
        
        XCTAssertFalse(anyAnimation.isFinished)
        
        anyAnimation.advance(by: 1.0)
        
        XCTAssertTrue(anyAnimation.isFinished)
    }
    
    func testValues() {
        
        let wrappedAnimation = SimulatedAnimation(
            function: SpringFunction(target: Vector2(repeating: 100)),
            value: CGPoint.zero,
            velocity: CGPoint.zero)
        
        let anyAnimation = AnyAnimation(wrappedAnimation)
        
        XCTAssertGreaterThan(Array(wrappedAnimation.steps()).count, 20)


        for (wrappedStep, anyStep) in zip(wrappedAnimation.steps(), anyAnimation.steps()) {
            XCTAssertEqual(wrappedStep.timeOffset, anyStep.timeOffset)
            XCTAssertEqual(wrappedStep.value, anyStep.value)
        }

    }

}
