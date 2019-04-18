extension Animator {
    
    enum State {
        case atRest(value: Value)
        case animating(animation: Animation<Value>)
        case simulating(simulation: Simulation<Value>)
        
        mutating func advance(by time: Double) {
            switch self {
            case .atRest: break
            case .animating(var animation):
                animation.advance(by: time)
                if animation.isFinished {
                    self = .atRest(value: animation.value)
                } else {
                    self = .animating(animation: animation)
                }
            case .simulating(var simulation):
                simulation.advance(by: time)
                if simulation.hasConverged {
                    self = .atRest(value: simulation.value)
                } else {
                    self = .simulating(simulation: simulation)
                }
            }
        }
        
        var isAtRest: Bool {
            switch self {
            case .atRest: return true
            case .animating: return false
            case .simulating: return false
            }
        }
        
        var value: Value {
            switch self {
            case .atRest(let value): return value
            case .animating(let animation): return animation.value
            case .simulating(let simulation): return simulation.value
            }
        }
        
        var velocity: Value {
            switch self {
            case .atRest(_): return .zero
            case .animating(let animation): return animation.velocity
            case .simulating(let simulation): return simulation.velocity
            }
        }
        
        mutating func animate(to finalValue: Value, duration: Double, timingFunction: TimingFunction) {
            let animation = Animation(
                from: self.value,
                to: finalValue,
                duration: duration,
                timingFunction: timingFunction)
            self = .animating(animation: animation)
        }
        
        mutating func simulate<T>(using function: T, initialVelocity: Value) where T: SimulationFunction, T.Value == Value {
            let simulation = Simulation(
                function: function,
                initialValue: self.value,
                initialVelocity: initialVelocity)
            
            self = .simulating(simulation: simulation)
        }
        
        mutating func simulate<T>(using function: T) where T: SimulationFunction, T.Value == Value {
            switch self {
            case .atRest, .animating:
                self.simulate(using: function, initialVelocity: self.velocity)
            case .simulating(var simulation):
                simulation.use(function: function)
                self = .simulating(simulation: simulation)
            }
        }
    }
    
}
