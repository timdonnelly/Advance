import XCTest
@testable import Advance


class SinkTests : XCTestCase {
    
    func testEvent() {
        let payload = 123
        
        let sink = Sink<Int>()
        
        var output: Int? = nil
        
        sink.observe { (value) -> Void in
            output = payload
        }
        
        sink.send(value: payload)
        
        XCTAssertEqual(output, payload)
        
    }
    
    func testRemoveObserver() {
        
        let payload = 123
        let sink = Sink<Int>()
        
        var output: Int? = nil
        
        let subscription = sink.observe { (value) -> Void in
            output = value
        }
        
        sink.send(value: payload)
        XCTAssertEqual(payload, output)
        
        output = nil
        subscription.unsubscribe()
        sink.send(value: payload)
        XCTAssertNil(output)
    }
}
