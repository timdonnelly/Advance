import CoreGraphics
import Advance


private enum GravitySimulationNode: Advanceable {
    case stationary(Vector2)
    case decaying(DynamicSolver<DecayFunction<Vector2>>)
    case pulling(DynamicSolver<GravityFunction>)
    
    var value: Vector2 {
        switch self {
        case .stationary(let v):
            return v
        case .decaying(let d):
            return d.value
        case .pulling(let s):
            return s.value
        }
    }
    
    var velocity: Vector2 {
        switch self {
        case .stationary(_):
            return Vector2.zero
        case .decaying(let d):
            return d.velocity
        case .pulling(let s):
            return s.velocity
        }
    }
    
    mutating func advance(by time: Double) {
        switch self {
        case .stationary(_):
            break
        case .decaying(var sim):
            sim.advance(by: time)
            self = sim.settled ? .stationary(sim.value) : .decaying(sim)
        case .pulling(var sim):
            sim.advance(by: time)
            self = sim.settled ? .stationary(sim.value) : .pulling(sim)
        }
    }
    
    var settled: Bool {
        switch self {
        case .stationary(_):
            return true
        case .pulling(_), .decaying(_):
            return false
        }
    }
    
    mutating func pull(to point: CGPoint) {
        if case var .pulling(sim) = self {
            sim.function.target = point.vector
            self = .pulling(sim)
            return
        }
        
        let f = GravityFunction(target: point.vector)
        let solver = DynamicSolver(function: f, value: value, velocity: velocity)
        self = .pulling(solver)
    }
    
    mutating func getDecay() {
        guard case let .pulling(sim) = self else { return }
        
        let f = DecayFunction<Vector2>()
        let solver = DynamicSolver(function: f, value: sim.value, velocity: sim.velocity)
        self = .decaying(solver)
    }
    
    mutating func reset(to value: CGPoint) {
        self = .stationary(value.vector)
    }
}


struct GravitySimulation: Advanceable {
    
    let rows: Int = 10
    let cols: Int = 10
    
    init() {
        for r in 0..<rows {
            nodes.append([])
            for _ in 0..<cols {
                let node = GravitySimulationNode.stationary(Vector2(x: 0.0, y: 0.0))
                nodes[r].append(node)
            }
        }
    }
    
    fileprivate var nodes: [[GravitySimulationNode]] = []
    
    mutating func reset(layoutBounds: CGRect) {
        target = nil
        
        let rowHeight = (layoutBounds.size.height / CGFloat(rows-1))
        let colWidth = (layoutBounds.size.width / CGFloat(cols-1))
        
        for r in 0..<rows {
            for c in 0..<cols {
                var p = layoutBounds.origin
                p.x += CGFloat(c) * colWidth
                p.y += CGFloat(r) * rowHeight
                nodes[r][c].reset(to: p)
            }
        }
    }
    
    var target: CGPoint? = nil {
        didSet {
            updateNodes()
        }
    }
    
    fileprivate mutating func updateNodes() {
        for r in 0..<rows {
            for c in 0..<cols {
                if let t = target {
                    nodes[r][c].pull(to: t)
                } else {
                    nodes[r][c].getDecay()
                }
            }
        }
    }
    
    func getPosition(row: Int, col: Int) -> CGPoint {
      return CGPoint(vector: nodes[row][col].value)
    }
    
    mutating func advance(by time: Double) {
        for r in 0..<rows {
            for c in 0..<cols {
                nodes[r][c].advance(by: time)
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
