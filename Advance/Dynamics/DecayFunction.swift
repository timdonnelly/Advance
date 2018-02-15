/// Gradually reduces velocity until it equals `Vector.zero`.
public struct DecayFunction<VectorType: Vector>: DynamicFunction {
    
    /// How close to 0 each component of the velocity must be before the
    /// simulation is allowed to settle.
    public var threshold: Scalar = 0.1
    
    /// How much to erode the velocity.
    public var drag: Scalar = 3.0
    
    /// Creates a new `DecayFunction` instance.
    public init() {}
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(value: VectorType, velocity: VectorType) -> VectorType {
        return -drag * velocity
    }
    
    /// Returns `true` if the simulation can become settled.
    public func canSettle(value: VectorType, velocity: VectorType) -> Bool {
        let min = VectorType(scalar: -threshold)
        let max = VectorType(scalar: threshold)
        return velocity.clamped(min: min, max: max) == velocity
    }
    
    /// Returns the value to settle on.
    public func settledValue(value: VectorType, velocity: VectorType) -> VectorType {
        return value
    }
}
