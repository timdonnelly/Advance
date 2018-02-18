//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import Advance

PlaygroundPage.current.needsIndefiniteExecution = true

let asdf = SpringFunction(target: CGPoint.zero.vector)

CGPoint(x: 30, y: 40)
    .animation(to: .zero, duration: 1.0)
    .run()
    .onChange { (point) in
            print(point)
    }
