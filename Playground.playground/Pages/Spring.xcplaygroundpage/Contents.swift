import UIKit
import PlaygroundSupport
import Advance

let animation = 0.0.springAnimation(to: 100.0, initialVelocity: 0.0, tension: 20.0, damping: 2.0, threshold: 0.1)

animation.allValues().map { $0 }
