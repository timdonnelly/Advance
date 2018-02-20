/// An animation that is powered by a simulation function (e.g. a spring or decay function).
public struct SimulatedAnimation<Value, T>: Animation where Value: VectorConvertible, T: SimulationFunction, Value.VectorType == T.VectorType {
    
    private var simulation: Simulation<T>
    
    /// Initializes a new animation with given initial state.
    public init(function: T, value: Value, velocity: Value) {
        self.simulation = Simulation(function: function, value: value.vector, velocity: velocity.vector)
    }
    
    public mutating func advance(by time: Double) {
        simulation.advance(by: time)
    }
    
    public var value: Value {
        return Value(vector: simulation.value)
    }
    
    public var velocity: Value {
        return Value(vector: simulation.velocity)
    }
    
    public var isFinished: Bool {
        return simulation.hasConverged
    }
    
}
