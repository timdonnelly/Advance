import XCTest
@testable import Advance


class EventTests : XCTestCase {
    func testEvent() {
        let payload = 123
        let event = Event<Int>()
        
        let exp1 = expectationWithDescription("non-keyed")
        let exp2 = expectationWithDescription("keyed")
        
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
        
        waitForExpectationsWithTimeout(3.0) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
    
    func testClosing() {
        let payload = 123
        let event = Event<Int>()
        let exp = expectationWithDescription("exp")
        
        event.observe { (p) -> Void in
            XCTAssertEqual(p, payload)
            exp.fulfill()
        }
        
        event.close(payload)
        XCTAssertTrue(event.closed)
        
        waitForExpectationsWithTimeout(3.0) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
}
