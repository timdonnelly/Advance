//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
import Advance


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


let initial = CGSize(width: 32.0, height: 32.0)
let final = UIScreen.mainScreen().bounds.size

0.0.animateTo(3.0, duration: 2.0, timingFunction: LinearTimingFunction()) { (value) in
    NSLog("val: \(value)")
}