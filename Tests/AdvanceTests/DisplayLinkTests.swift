import XCTest
@testable import Advance


class DisplayLinkTests : XCTestCase {
    
    var link: DisplayLink! = nil
    
    override func setUp() {
        link = DisplayLink()
    }
    
    override func tearDown() {
        link = nil
    }
    
    func testCallback() {
        let exp = expectation(description: "callback")
        
        var fulfilled = false
        
        link.onFrame = { (frame) in
            guard fulfilled == false else { return }
            fulfilled = true
            exp.fulfill()
        }
        
        link.isPaused = false
        
        waitForExpectations(timeout: 0.5) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
    
    func testPausing() {
        link.isPaused = false
        
        var gotCallback = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { () -> Void in
            self.link.isPaused = true
            self.link.onFrame = { (frame) in
                gotCallback = true
            }
        }
        
        let timeoutDate = Date(timeIntervalSinceNow: 1.0)
        
        repeat {
            _ = RunLoop.current.run(mode: RunLoop.Mode.default, before: timeoutDate)
            if timeoutDate.timeIntervalSinceNow <= 0.0 {
                break
            }
        } while true
        
        XCTAssertEqual(gotCallback, false)
    }

    func testTimestamp() {
        let exp = expectation(description: "callback")
        
        var callbacks = 0
        var lastTimestamp: Double = 0
        
        link.onFrame = { (frame) in
            XCTAssertTrue(frame.timestamp > lastTimestamp, "timestamp \(frame.timestamp) was not larger than \(lastTimestamp) (frame #\(callbacks))")
            lastTimestamp = frame.timestamp
            
            if callbacks == 10 { // test 10 frames before fulfilling
                exp.fulfill()
            }
            
            callbacks += 1
        }
        
        link.isPaused = false
        
        waitForExpectations(timeout: 0.5) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
    
    static var allTests = [
        ("testCallback", testCallback),
        ("testPausing", testPausing),
        ("testTimestamp", testTimestamp),
    ]
}
