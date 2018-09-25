/// Conforming types implement a dynamic function that models changes to
/// a vector over time.

public protocol SimulationFunction {
    
    /// The type of vector driven by the simulation
    associatedtype VectorType: Vector
    
    /// The computed acceleration for a given simulation state.
    ///
    /// - parameter value: The current value of the simulation.
    /// - parameter velocity: The current velocity of the simulation.
    /// - returns: A vector containing the acceleration (in units per second)
    ///   based on `value` and `velocity`.
    func acceleration(for state: SimulationState<VectorType>) -> VectorType
    
    /// Determines whether the simulation can converge (come to rest) for the
    /// given state.
    func convergence(for state: SimulationState<VectorType>) -> Convergence<VectorType>

}

/// Returned by a simulation function to indicate whether a simulation should
/// converge (come to rest) for a given state.
public enum Convergence<T> where T: Vector {
    
    /// The simulation should keep running.
    case keepRunning
    
    /// The simulation should converge (come to rest) with the given value.
    case converge(atValue: T)
}


public extension SimulationFunction {
    
    fileprivate typealias Derivative = SimulationState
    
    /// Integrates time into an existing simulation state, returning the resulting
    /// simulation state.
    ///
    /// The integration is done via RK4.
    public func integrate(state: SimulationState<VectorType>, time: Double) -> SimulationState<VectorType> {
        
        let initial = Derivative(value:VectorType.zero, velocity: VectorType.zero)
        
        let a = evaluate(state: state, time: 0.0, derivative: initial)
        let b = evaluate(state: state, time: time * 0.5, derivative: a)
        let c = evaluate(state: state, time: time * 0.5, derivative: b)
        let d = evaluate(state: state, time: time, derivative: c)
        
        var dxdt = a.value
        dxdt += (2.0 * (b.value + c.value)) + d.value
        dxdt = Scalar(1.0/6.0) * dxdt
        
        var dvdt = a.velocity
        dvdt += (2.0 * (b.velocity + c.velocity)) + d.velocity
        dvdt = Scalar(1.0/6.0) * dvdt
        
        
        let val = state.value + Scalar(time) * dxdt
        let vel = state.velocity + Scalar(time) * dvdt
        
        return SimulationState(value: val, velocity: vel)
    }
    
    private func evaluate(state: SimulationState<VectorType>, time: Double, derivative: Derivative<VectorType>) -> Derivative<VectorType> {
        var nextState = state
        nextState.value += Scalar(time) * derivative.value
        nextState.velocity += Scalar(time) * derivative.velocity
        return Derivative(
            value: nextState.velocity,
            velocity: acceleration(for: nextState))
    }
    
}
