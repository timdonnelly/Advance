/// Conforming types implement a dynamic function that models changes to
/// a vector over time.

public protocol SimulationFunction {
    
    /// The type of vector driven by the simulation
    associatedtype VectorType: SIMD where VectorType.Scalar == Double
    
    /// The computed acceleration for a given simulation state.
    ///
    /// - parameter value: The current value of the simulation.
    /// - parameter velocity: The current velocity of the simulation.
    /// - returns: A vector containing the acceleration (in units per second)
    ///   based on `value` and `velocity`.
    func acceleration(value: VectorType, velocity: VectorType) -> VectorType
    
    /// Determines whether the simulation can converge (come to rest) for the
    /// given state.
    func convergence(value: VectorType, velocity: VectorType) -> Convergence<VectorType>

}

/// Returned by a simulation function to indicate whether a simulation should
/// converge (come to rest) for a given state.
public enum Convergence<T> where T: SIMD, T.Scalar == Double {
    
    /// The simulation should keep running.
    case keepRunning
    
    /// The simulation should converge (come to rest) with the given value.
    case converge(atValue: T)
}


extension SimulationFunction {
    
    private typealias Derivative = (value: VectorType, velocity: VectorType)
    
    /// Integrates time into an existing simulation state, returning the resulting
    /// simulation state.
    ///
    /// The integration is done via RK4.
    public func integrate(value: VectorType, velocity: VectorType, time: Double) -> (value: VectorType, velocity: VectorType) {
        
        let initial = Derivative(value: .zero, velocity: .zero)
        
        let a = evaluate(value: value, velocity: velocity, time: 0.0, derivative: initial)
        let b = evaluate(value: value, velocity: velocity, time: time * 0.5, derivative: a)
        let c = evaluate(value: value, velocity: velocity, time: time * 0.5, derivative: b)
        let d = evaluate(value: value, velocity: velocity, time: time, derivative: c)
        
        var dxdt = a.value
        dxdt += (2.0 * (b.value + c.value)) + d.value
        dxdt = Double(1.0/6.0) * dxdt
        
        var dvdt = a.velocity
        dvdt += (2.0 * (b.velocity + c.velocity)) + d.velocity
        dvdt = Double(1.0/6.0) * dvdt
        
        return (
            value: value + (time * dxdt),
            velocity: velocity + (time * dvdt)
        )
        
    }
    
    private func evaluate(value: VectorType, velocity: VectorType, time: Double, derivative: Derivative) -> Derivative {
        let nextValue = value + (time * derivative.value)
        let nextVelocity = velocity + (time * derivative.velocity)
        return Derivative(
            value: nextVelocity,
            velocity: acceleration(value: nextValue, velocity: nextVelocity))
    }
    
}
