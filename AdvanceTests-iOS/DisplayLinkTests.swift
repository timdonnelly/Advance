import XCTest
@testable import Advance


class DisplayLinkTests : XCTestCase {
    
    var displayLink: DisplayLink! = nil
    
    override func setUp() {
        displayLink = DisplayLink()
    }
    
    override func tearDown() {
        displayLink = nil
    }
    
    func testCallback() {
        let exp = expectationWithDescription("callback")
        
        var fulfilled = false
        
        displayLink.callback = { (frame) in
            guard fulfilled == false else { return }
            fulfilled = true
            exp.fulfill()
        }
        
        displayLink.paused = false
        
        waitForExpectationsWithTimeout(0.5) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
    
    func testPausing() {
        displayLink.paused = false
        
        var gotCallback = false
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.displayLink.paused = true
            self.displayLink.callback = { (frame) in
                gotCallback = true
            }
        }
        
        let timeoutDate = NSDate(timeIntervalSinceNow: 1.0)
        
        repeat {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: timeoutDate)
            if timeoutDate.timeIntervalSinceNow <= 0.0 {
                break
            }
        } while true
        
        XCTAssertEqual(gotCallback, false)
    }

    func testTimestamp() {
        let exp = expectationWithDescription("callback")
        
        var callbacks = 0
        var lastTimestamp: Double = 0
        
        displayLink.callback = { (frame) in
            XCTAssertTrue(frame.timestamp > lastTimestamp, "timestamp \(frame.timestamp) was not larger than \(lastTimestamp) (frame #\(callbacks))")
            lastTimestamp = frame.timestamp
            
            if callbacks == 10 { // test 10 frames before fulfilling
                exp.fulfill()
            }
            
            callbacks += 1
        }
        
        displayLink.paused = false
        
        waitForExpectationsWithTimeout(0.5) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
}
