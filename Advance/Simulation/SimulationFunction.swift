/// Conforming types implement a dynamic function that models changes to
/// a vector over time.

public protocol SimulationFunction {
    
    associatedtype VectorType: Vector
    
    /// The computed acceleration for a given simulation state.
    ///
    /// - parameter value: The current value of the simulation.
    /// - parameter velocity: The current velocity of the simulation.
    /// - returns: A vector containing the acceleration (in units per second)
    ///   based on `value` and `velocity`.
    func acceleration(for state: SimulationState<VectorType>) -> VectorType
    
    func convergence(for state: SimulationState<VectorType>) -> Convergence<VectorType>

}


public enum Convergence<T> where T: Vector {
    case keepRunning
    case converge(atValue: T)
}


/// RK4 Integration.
public extension SimulationFunction {
    
    fileprivate typealias Derivative = SimulationState
    
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
