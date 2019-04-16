/// An animation that is powered by a simulation function (e.g. a spring or decay function).
struct SimulationAnimation<Function>: Animation where Function: SimulationFunction {
    
    private var simulation: SimulationState<Function>
    
    /// Initializes a new animation with given initial state.
    init(function: Function, initialValue: Function.Value, initialVelocity: Function.Value) {
        self.simulation = SimulationState(function: function, initialValue: initialValue.vector, initialVelocity: initialVelocity.vector)
    }
    
    mutating func advance(by time: Double) {
        simulation.advance(by: time)
    }
    
    var value: Function.Value {
        return Function.Value(vector: simulation.value)
    }
    
    var velocity: Function.Value {
        return Function.Value(vector: simulation.velocity)
    }
    
    var isFinished: Bool {
        return simulation.hasConverged
    }
    
}
