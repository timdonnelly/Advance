import XCTest
@testable import Advance


class EventTests : XCTestCase {
    func testEvent() {
        let payload = 123
        let event = Event<Int>()
        
        let exp1 = expectation(description: "non-keyed")
        let exp2 = expectation(description: "keyed")
        
        event.observe { (p) -> Void in
            XCTAssertEqual(p, payload)
            exp1.fulfill()
        }
        
        event.observe({ (p) -> Void in
            XCTAssertEqual(p, payload)
            exp2.fulfill()
            }, key: "keyed")
        
        event.fire(payload)
        XCTAssertFalse(event.closed)
        
        waitForExpectations(timeout: 3.0) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
    
    func testClosing() {
        let payload = 123
        let event = Event<Int>()
        let exp = expectation(description: "exp")
        
        event.observe { (p) -> Void in
            XCTAssertEqual(p, payload)
            exp.fulfill()
        }
        
        event.close(payload)
        XCTAssertTrue(event.closed)
        
        waitForExpectations(timeout: 3.0) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
}
