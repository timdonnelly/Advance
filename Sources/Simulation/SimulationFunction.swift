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
