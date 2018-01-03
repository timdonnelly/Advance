/// Conforming types implement a dynamic function that models changes to
/// a vector over time.
public protocol DynamicFunction {
    associatedtype VectorType: Vector
    
    /// The computed acceleration for a given simulation state.
    ///
    /// - parameter value: The current value of the simulation.
    /// - parameter velocity: The current velocity of the simulation.
    /// - returns: A vector containing the acceleration (in units per second)
    ///   based on `value` and `velocity`.
    func acceleration(value: VectorType, velocity: VectorType) -> VectorType
    
    /// Returns `true` if the simulation should be allowed to enter its settled
    /// state. For example, a decay function may check that `velocity` is below
    /// a minimum threshold.
    func canSettle(value: VectorType, velocity: VectorType) -> Bool
    
    /// Returns the value for the simulation as it enters the settled state.
    ///
    /// - parameter value: The current value of the simulation.
    /// - parameter velocity: The current velocity of the simulation.
    /// - returns: The value that the simulation will settle on.
    func settledValue(value: VectorType, velocity: VectorType) -> VectorType
}
