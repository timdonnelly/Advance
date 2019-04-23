import XCTest
@testable import Advance


class AnimatorTests: XCTestCase {
    
    
    func testTimedAnimationsFinishOnTargetValue() {
        
        let animator = Animator(initialValue: 0.0)
        
        let toValue = 10.0
        
        let finalValueExpectation = expectation(description: "Animator reaches the correct value")
        
        animator.onChange = { value in
            if value == toValue {
                finalValueExpectation.fulfill()
            }
        }
        
        animator.animate(to: toValue, duration: 1.0)
        
        
        wait(for: [finalValueExpectation], timeout: 2.0)
        
    }
    
    func testCancelRunningAnimationRemainsOnCurrentValue() {
        
        let animator = Animator(initialValue: 0.0)
        let toValue = 10.0
        animator.animate(to: toValue, duration: 1.0)
        
        let finishedExpectation = expectation(description: "The animator reached the halfway point")

        animator.onChange = { [weak animator] value in
            guard value > toValue/2.0 else { return }
            
            // Stop listening
            animator!.onChange = nil
            
            XCTAssert(animator!.value < toValue)
            let currentValue = animator!.value
            animator?.cancelRunningAnimation()
            XCTAssertEqual(currentValue, animator!.value)
            
            finishedExpectation.fulfill()
        }
        
        animator.animate(to: toValue, duration: 1.0)
        
        wait(for: [finishedExpectation], timeout: 2.0)
        
    }
    
    static var allTests = [
        ("testTimedAnimationsFinishOnTargetValue", testTimedAnimationsFinishOnTargetValue),
        ("testCancelRunningAnimationRemainsOnCurrentValue", testCancelRunningAnimationRemainsOnCurrentValue)
    ]
    
}
