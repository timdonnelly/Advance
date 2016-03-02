//: [Previous](@previous)

import UIKit
import XCPlayground
import Advance


var f = SpringFunction(target: 0.0)
var sim = DynamicSimulation(function: f, value: 0.0)

sim.velocity = 800.0

while sim.settled == false {
    sim.advance(0.016)
    XCPlaygroundPage.currentPage.captureValue(sim.value, withIdentifier: "Sprig sim")
}



sim.function.target = 20.0

while sim.settled == false {
    sim.advance(0.016)
    XCPlaygroundPage.currentPage.captureValue(sim.value, withIdentifier: "Sprig sim")
}

sim.function.configuration.damping = 1.0
sim.function.target = 0.0

while sim.settled == false {
    sim.advance(0.016)
    XCPlaygroundPage.currentPage.captureValue(sim.value, withIdentifier: "Sprig sim")
}
