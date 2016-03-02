//: [Previous](@previous)

import UIKit
import XCPlayground
import Advance

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let a = Animatable(value: 0.0)

a.changed.observe { (val) in
    NSLog("value: \(val)")
}

a.value = 4.0

a.value = 20.0

a.animateTo(10.0) { (finished) in
    var cfg = SpringConfiguration()
    cfg.damping = 2.0
    a.springTo(0.0, initialVelocity: 0.0, configuration: cfg, completion: nil)
}
