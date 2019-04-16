/// Gradually reduces velocity until it equals `Vector.zero`.
public struct DecayFunction<T>: SimulationFunction where T: SIMD, T.Scalar == Double {
    
    /// How close to 0 each component of the velocity must be before the
    /// simulation is allowed to converge.
    public var threshold: Double = 0.1
    
    /// How much to erode the velocity.
    public var drag: Double = 3.0
    
    /// Creates a new `DecayFunction` instance.
    public init() {}
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(value: T, velocity: T) -> T {
        return -drag * velocity
    }
    
    public func convergence(value: T, velocity: T) -> Convergence<T> {
        let min = T(repeating: -threshold)
        let max = T(repeating: threshold)
        if velocity.clamped(min: min, max: max) == velocity {
            return .converge(atValue: value)
        } else {
            return .keepRunning
        }
    }
    
}
