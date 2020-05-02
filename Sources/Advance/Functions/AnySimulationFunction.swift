import SwiftUI

/// A type-erased simulation function.
public struct AnySimulationFunction<Value>: SimulationFunction where Value: Animatable {
    
    private let _acceleration: (Value.AnimatableData, Value.AnimatableData) -> Value.AnimatableData
    private let _convergence: (Value.AnimatableData, Value.AnimatableData) -> Convergence<Value>
    
    public init<T: SimulationFunction>(_ wrapped: T) where T.Value == Value {
        _acceleration = wrapped.acceleration
        _convergence = wrapped.convergence
    }
    
    public func acceleration(value: Value.AnimatableData, velocity: Value.AnimatableData) -> Value.AnimatableData {
        return _acceleration(value, velocity)
    }
    
    public func convergence(value: Value.AnimatableData, velocity: Value.AnimatableData) -> Convergence<Value> {
        return _convergence(value, velocity)
    }
    
}

