/// An animation that is powered by a simulation function (e.g. a spring or decay function).
struct SimulationAnimation<Value, T>: Animation where Value: VectorConvertible, T: SimulationFunction, Value.VectorType == T.VectorType {
    
    private var simulation: SimulationState<T>
    
    /// Initializes a new animation with given initial state.
    init(function: T, value: Value, velocity: Value) {
        self.simulation = SimulationState(function: function, value: value.vector, velocity: velocity.vector)
    }
    
    mutating func advance(by time: Double) {
        simulation.advance(by: time)
    }
    
    var value: Value {
        return Value(vector: simulation.value)
    }
    
    var velocity: Value {
        return Value(vector: simulation.velocity)
    }
    
    var isFinished: Bool {
        return simulation.hasConverged
    }
    
}
