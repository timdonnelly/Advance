//: [Previous](@previous)

import UIKit
import XCPlayground
import Advance

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


let s = Spring(value: 0.0)
s.configuration.tension = 200.0
s.configuration.damping = 20.0
s.configuration.threshold = 1.0

s.changed.observe { (val) in
XCPlaygroundPage.currentPage.captureValue(val, withIdentifier: "Spring value")
}

s.target = 200.0

var t = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)*2)
dispatch_after(t, dispatch_get_main_queue()) { 
    s.target = 0.0
}
