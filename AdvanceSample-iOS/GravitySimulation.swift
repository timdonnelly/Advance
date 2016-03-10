/*

Copyright (c) 2016, Storehouse Media Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

import CoreGraphics
import Advance


private enum GravitySimulationNode: Advanceable {
    case Static(Vector2)
    case Decay(DynamicSolver<DecayFunction<Vector2>>)
    case Pull(DynamicSolver<GravityFunction>)
    
    var value: Vector2 {
        switch self {
        case .Static(let v):
            return v
        case .Decay(let d):
            return d.value
        case .Pull(let s):
            return s.value
        }
    }
    
    var velocity: Vector2 {
        switch self {
        case .Static(_):
            return Vector2.zero
        case .Decay(let d):
            return d.velocity
        case .Pull(let s):
            return s.velocity
        }
    }
    
    mutating func advance(elapsed: Double) {
        switch self {
        case .Static(_):
            break
        case .Decay(var sim):
            sim.advance(elapsed)
            self = sim.settled ? .Static(sim.value) : .Decay(sim)
        case .Pull(var sim):
            sim.advance(elapsed)
            self = sim.settled ? .Static(sim.value) : .Pull(sim)
        }
    }
    
    var settled: Bool {
        switch self {
        case .Static(_):
            return true
        case .Pull(_), .Decay(_):
            return false
        }
    }
    
    mutating func pullTo(point: CGPoint) {
        if case var .Pull(sim) = self {
            sim.function.target = point.vector
            self = .Pull(sim)
            return
        }
        
        let f = GravityFunction(target: point.vector)
        let solver = DynamicSolver(function: f, value: value, velocity: velocity)
        self = .Pull(solver)
    }
    
    mutating func decay() {
        guard case let .Pull(sim) = self else { return }
        
        let f = DecayFunction<Vector2>()
        let solver = DynamicSolver(function: f, value: sim.value, velocity: sim.velocity)
        self = .Decay(solver)
    }
    
    mutating func reset(to: CGPoint) {
        self = .Static(to.vector)
    }
}


struct GravitySimulation: Advanceable {
    
    let rows: Int = 10
    let cols: Int = 10
    
    init() {
        for r in 0..<rows {
            nodes.append([])
            for _ in 0..<cols {
                let node = GravitySimulationNode.Static(Vector2(0.0, 0.0))
                nodes[r].append(node)
            }
        }
    }
    
    private var nodes: [[GravitySimulationNode]] = []
    
    mutating func reset(layoutBounds: CGRect) {
        target = nil
        
        let rowHeight = (layoutBounds.size.height / CGFloat(rows-1))
        let colWidth = (layoutBounds.size.width / CGFloat(cols-1))
        
        for r in 0..<rows {
            for c in 0..<cols {
                var p = layoutBounds.origin
                p.x += CGFloat(c) * colWidth
                p.y += CGFloat(r) * rowHeight
                nodes[r][c].reset(p)
            }
        }
    }
    
    var target: CGPoint? = nil {
        didSet {
            updateNodes()
        }
    }
    
    private mutating func updateNodes() {
        for r in 0..<rows {
            for c in 0..<cols {
                if let t = target {
                    nodes[r][c].pullTo(t)
                } else {
                    nodes[r][c].decay()
                }
            }
        }
    }
    
    func getPosition(row: Int, col: Int) -> CGPoint {
        return CGPoint(vector: nodes[row][col].value)
    }
    
    mutating func advance(elapsed: Double) {
        for r in 0..<rows {
            for c in 0..<cols {
                nodes[r][c].advance(elapsed)
            }
        }
    }
    
    var settled: Bool {
        for r in 0..<rows {
            for c in 0..<cols {
                if nodes[r][c].settled == false {
                    return false
                }
            }
        }
        return true
    }
}