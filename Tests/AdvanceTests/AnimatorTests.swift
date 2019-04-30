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
    
    func testCancelRunningAnimationCallsCompletion() {
        
        let finishedExpectation = expectation(description: "The animator called completion")

        
        let animator = Animator(initialValue: 0.0)
        let toValue = 10.0
        animator.animate(to: toValue, duration: 1.0, completion: { reason in
            if reason == .interrupted {
                finishedExpectation.fulfill()
            }
        })
        
        animator.onChange = { [weak animator] value in
            guard value > toValue/2.0 else { return }
            animator?.cancelRunningAnimation()
        }
        
        wait(for: [finishedExpectation], timeout: 2.0)
        
    }
    
    func testAnimationCallsCompletion() {
        
        let finishedExpectation = expectation(description: "The animator called completion")
        
        
        let animator = Animator(initialValue: 0.0)
        let toValue = 10.0
        animator.animate(to: toValue, duration: 1.0, completion: { reason in
            if reason == .finished {
                finishedExpectation.fulfill()
            }
        })
        
        wait(for: [finishedExpectation], timeout: 2.0)
        
    }
    
    func testSimulationCallsCompletion() {
        
        let finishedExpectation = expectation(description: "The animator called completion")
        
        
        let animator = Animator(initialValue: 0.0)
        let spring = SpringFunction(target: 10.0, tension: 300, damping: 30, threshold: 0.1)
        animator.simulate(
            using: spring,
            completion: { reason in
                if reason == .finished {
                    finishedExpectation.fulfill()
                }
            })
        
        let estimatedDuration = spring.estimatedConvergence(initialValue: 0.0, initialVelocity: 0.0, maximumDuration: 20.0)!.duration
        
        wait(for: [finishedExpectation], timeout: estimatedDuration)
        
    }
    
    static var allTests = [
        ("testTimedAnimationsFinishOnTargetValue", testTimedAnimationsFinishOnTargetValue),
        ("testCancelRunningAnimationRemainsOnCurrentValue", testCancelRunningAnimationRemainsOnCurrentValue)
    ]
    
}
