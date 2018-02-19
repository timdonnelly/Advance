import XCTest
@testable import Advance


class LoopTests : XCTestCase {
    
    var loop: Loop! = nil
    
    override func setUp() {
        loop = Loop()
    }
    
    override func tearDown() {
        loop = nil
    }
    
    func testCallback() {
        let exp = expectation(description: "callback")
        
        var fulfilled = false
        
        loop.observe { (frame) in
            guard fulfilled == false else { return }
            fulfilled = true
            exp.fulfill()
        }
        
        loop.paused = false
        
        waitForExpectations(timeout: 0.5) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
    
    func testPausing() {
        loop.paused = false
        
        var gotCallback = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.loop.paused = true
            self.loop.observe { (frame) in
                gotCallback = true
            }
        }
        
        let timeoutDate = Date(timeIntervalSinceNow: 1.0)
        
        repeat {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: timeoutDate)
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
        
        loop.observe { (frame) in
            XCTAssertTrue(frame.timestamp > lastTimestamp, "timestamp \(frame.timestamp) was not larger than \(lastTimestamp) (frame #\(callbacks))")
            lastTimestamp = frame.timestamp
            
            if callbacks == 10 { // test 10 frames before fulfilling
                exp.fulfill()
            }
            
            callbacks += 1
        }
        
        loop.paused = false
        
        waitForExpectations(timeout: 0.5) { (error) -> Void in
            guard error == nil else { XCTFail(); return }
        }
    }
}
