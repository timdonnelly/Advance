/// Gradually reduces velocity until it equals `Vector.zero`.
public struct DecayFunction<T>: SimulationFunction where T: Vector {
    
    /// How close to 0 each component of the velocity must be before the
    /// simulation is allowed to converge.
    public var threshold: Scalar = 0.1
    
    /// How much to erode the velocity.
    public var drag: Scalar = 3.0
    
    /// Creates a new `DecayFunction` instance.
    public init() {}
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(for state: SimulationState<T>) -> T {
        return -drag * state.velocity
    }
    
    public func convergence(for state: SimulationState<T>) -> Convergence<T> {
        let min = T(scalar: -threshold)
        let max = T(scalar: threshold)
        if state.velocity.clamped(min: min, max: max) == state.velocity {
            return .converge(atValue: state.value)
        } else {
            return .keepRunning
        }
    }
    
}


public extension Animator {

    /// Starts a decay animation with the current velocity of the property animator.
    @discardableResult
    public func decay(drag: Scalar = 3.0, threshold: Scalar = 0.1) -> AnimationRunner<Value> {
        return decay(initialVelocity: velocity, drag: drag, threshold: threshold)
    }
    
    /// Starts a decay animation with the given initial velocity.
    @discardableResult
    public func decay(initialVelocity: Value, drag: Scalar = 3.0, threshold: Scalar = 0.1) -> AnimationRunner<Value> {

        let animation = value
            .decayAnimation(
                initialVelocity: initialVelocity,
                drag: drag,
                threshold: threshold)
        
        return animate(with: animation)
        
    }
}


public extension VectorConvertible {
    
    /// Returns a decay animation with the given properties.
    public func decayAnimation(initialVelocity: Self, drag: Scalar = 3.0, threshold: Scalar = 0.1) -> SimulatedAnimation<Self, DecayFunction<Self.VectorType>> {
        var function = DecayFunction<Self.VectorType>()
        function.drag = drag
        function.threshold = threshold
        return SimulatedAnimation(function: function, value: self, velocity: initialVelocity)
    }
    
}
