//: [Previous](@previous)

import UIKit
import XCPlayground
import Advance


let numberOfTicks = 100.0

let timingFunction = UnitBezier(preset: .EaseInEaseOut)
var a = BasicAnimation(from: 0.0, to: 10.0, duration: 1.0, timingFunction: timingFunction)


XCPlaygroundPage.currentPage.captureValue(a.value, withIdentifier: "Basic Animation")
while a.finished == false {
    a.advance(1.0/numberOfTicks)
    XCPlaygroundPage.currentPage.captureValue(a.value, withIdentifier: "Basic Animation")
    NSLog("Basic animation: \(a.value)")
}
