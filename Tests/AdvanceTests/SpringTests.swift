import XCTest
@testable import Advance


class SpringTests: XCTestCase {
    
    
    func testReachesTargetValue() {
        
        let spring = Spring(initialValue: 0.0)
        spring.tension = 500.0
        spring.damping = 40.0
        spring.threshold = 0.01
        
        let toValue = 10.0
        
        let finalValueExpectation = expectation(description: "Spring reaches the correct value")
        
        spring.onChange = { value in
            if value == toValue {
                finalValueExpectation.fulfill()
            }
        }
        
        let estimatedConvergence = SpringFunction(
            target: toValue,
            tension: spring.tension,
            damping: spring.damping,
            threshold: spring.threshold)
            .estimatedConvergence(
                initialValue: 0.0,
                initialVelocity: 10.0,
                maximumDuration: 10.0)!
        
        spring.target = toValue
        
        wait(for: [finalValueExpectation], timeout: estimatedConvergence.duration)
    }
    
    static var allTests = [
        ("testReachesTargetValue", testReachesTargetValue),
    ]
    
}
