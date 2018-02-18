/// Given a starting velocity, `DecayAnimation` will slowly bring the value
/// to a stop (where `velocity` == `Value.zero`).
///
/// `DecayAnimation` uses a `DynamicSolver` containing a `DecayFunction`
/// internally.
public struct DecayAnimation<Value: VectorConvertible>: Animation {
    
    fileprivate var solver: Simulation<DecayFunction<Value>>
    
    /// Creates a new `DecayAnimation` instance.
    ///
    /// - parameter threshold: The minimum velocity, below which the animation
    ///   will finish.
    /// - parameter from: The initial value of the animation.
    /// - parameter velocity: The velocity at time `0`.
    public init(threshold: Scalar = 0.1, from: Value = Value.zero, velocity: Value = Value.zero) {
        var f = DecayFunction<Value>()
        f.threshold = threshold
        f.drag = 3.0
        solver = Simulation(function: f, value: from, velocity: velocity)
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(by time: Double) {
        solver.advance(by: time)
    }
    
    /// Returns `true` if the velocity has settled at 0.
    public var finished: Bool {
        return solver.settled
    }
    
    /// The current value.
    public var value: Value {
        get { return solver.value }
        set { solver.value = newValue }
    }
    
    /// The current velocity.
    public var velocity: Value {
        get { return solver.velocity }
        set { solver.velocity = newValue }
    }
    
    /// Each component of the simulation's velocity must be within this distance
    /// of 0.0 for the animation to complete.
    public var threshold: Scalar {
        get { return solver.function.threshold }
        set { solver.function.threshold = newValue }
    }
    
    /// The strength with which the velocity will be reduced. The acceleration
    /// for the simulation is calculated as `-drag * velocity`. Default: `3.0`.
    public var drag: Scalar {
        get { return solver.function.drag }
        set { solver.function.drag = newValue }
    }
}
