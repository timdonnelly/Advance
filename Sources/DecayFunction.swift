/// Gradually reduces velocity until it equals `Vector.zero`.
public struct DecayFunction<T>: SimulationFunction where T: VectorConvertible {
    
    /// How close to 0 each component of the velocity must be before the
    /// simulation is allowed to converge.
    public var threshold: Double
    
    /// How much to erode the velocity.
    public var drag: Double
    
    /// Creates a new `DecayFunction` instance.
    public init(threshold: Double = 0.1, drag: Double = 3.0) {
        self.threshold = threshold
        self.drag = drag
    }
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(value: T.VectorType, velocity: T.VectorType) -> T.VectorType {
        return -drag * velocity
    }
    
    public func convergence(value: T.VectorType, velocity: T.VectorType) -> Convergence<T> {
        let min = T.VectorType(repeating: -threshold)
        let max = T.VectorType(repeating: threshold)
        if clamp(value: velocity, min: min, max: max) == velocity {
            return .converge(atValue: value)
        } else {
            return .keepRunning
        }
    }
    
}


extension Animator {
    
    /// Starts a decay animation with the current velocity of the property animator.
    public func decay(drag: Double = 3.0, threshold: Double = 0.1) {
        decay(initialVelocity: velocity, drag: drag, threshold: threshold)
    }
    
    /// Starts a decay animation with the given initial velocity.
    public func decay(initialVelocity: Value, drag: Double = 3.0, threshold: Double = 0.1) {
        let function = DecayFunction<Value>(threshold: threshold, drag: drag)
        simulate(using: function, initialVelocity: initialVelocity)
    }
}
