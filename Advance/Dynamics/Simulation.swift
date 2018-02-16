/// Conforming types implement a dynamic function that models changes to
/// a vector over time.

public protocol AccelerationFunction {
    
    associatedtype VectorType: Vector
    
    /// The computed acceleration for a given simulation state.
    ///
    /// - parameter value: The current value of the simulation.
    /// - parameter velocity: The current velocity of the simulation.
    /// - returns: A vector containing the acceleration (in units per second)
    ///   based on `value` and `velocity`.
    func acceleration(for state: DynamicsState<VectorType>) -> VectorType
    
}

public protocol Simulation: AccelerationFunction {
    func status(for state: DynamicsState<VectorType>) -> SimulationStatus<VectorType>
}

public enum SimulationStatus<T> where T: Vector {
    case running
    case settled(value: T)
}
