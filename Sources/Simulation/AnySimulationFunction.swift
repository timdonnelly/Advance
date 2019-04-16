/// Gradually reduces velocity until it equals `Vector.zero`.
public struct AnySimulationFunction<Value>: SimulationFunction where Value: VectorConvertible {
    
    private let _acceleration: (Value.VectorType, Value.VectorType) -> Value.VectorType
    private let _convergence: (Value.VectorType, Value.VectorType) -> Convergence<Value>
    
    public init<T: SimulationFunction>(_ wrapped: T) where T.Value == Value {
        _acceleration = wrapped.acceleration
        _convergence = wrapped.convergence
    }

    public func acceleration(value: Value.VectorType, velocity: Value.VectorType) -> Value.VectorType {
        return _acceleration(value, velocity)
    }
    
    public func convergence(value: Value.VectorType, velocity: Value.VectorType) -> Convergence<Value> {
        return _convergence(value, velocity)
    }
    
}

