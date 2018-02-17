/// The `SpringAnimation` struct is an implementation of
/// `ValueAnimation` that uses a configurable spring function to animate
/// the value.
///
/// Spring animations do not have a duration. Instead, you should configure
/// the properties in 'configuration' to customize the way the spring will
/// change the value as the simulation advances. The animation is finished
/// when the spring has come to rest at its target value.
///
/// SpringAnimation instances use a `DynamicSolver` containing a
/// `SpringFunction` internally to perform the spring calculations.
public struct SpringAnimation<Value: VectorConvertible>: Animation {
    
    // The underlying spring simulation.
    fileprivate var solver: DynamicSolver<SpringFunction<Value>>
    
    /// Creates a new `SpringAnimation` instance.
    ///
    /// - parameter from: The value of the animation at time `0`.
    /// - parameter target: The final value that the spring will settle on at
    ///   the end of the animation.
    /// - parameter velocity: The initial velocity at the start of the animation.
    public init(from: Value, target: Value, velocity: Value = Value.zero) {
        let f = SpringFunction(target: target)
        solver = DynamicSolver(function: f, value: from, velocity: velocity)
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(by time: Double) {
        solver.advance(by: time)
    }
    
    /// Returns `true` if the spring has reached a settled state.
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
    
    
    /// The value that the spring will move toward.
    public var target: Value {
        get { return solver.function.target }
        set { solver.function.target = newValue }
    }
    
    /// The configuration of the underlying spring simulation.
    public var configuration: SpringConfiguration {
        get { return solver.function.configuration }
        set { solver.function.configuration = newValue }
    }
}


public extension Animatable {
    
    /// Animates to the given value using a spring function.
    ///
    /// - parameter to: The value to animate to.
    /// - parameter initialVelocity: An optional velocity to use at time `0`.
    ///   If no velocity is given, the current velocity of the `Animatable` instance
    ///   will be used (if another animation is in progress).
    /// - parameter configuration: A spring configuration instance to use.
    /// - parameter completion: A closure that will be called at the end of the
    ///   animation.
    public func spring(to target: Value, initialVelocity: Value? = nil, configuration: SpringConfiguration = SpringConfiguration(), completion: Completion? = nil) {
        var a = SpringAnimation(from: value, target: target, velocity: initialVelocity ?? velocity)
        a.configuration = configuration
        animate(with: a, completion: completion)
    }
}

public extension VectorConvertible {
    
    /// Animates to the given value using a spring function.
    ///
    /// - parameter to: The value to animate to.
    /// - parameter callback: A closure that will be called at each step of the animation.
    /// - returns: The animator instance that is powering the animation.
    public func spring(to target: Self, configuration: SpringConfiguration, callback: @escaping (Self) -> Void) -> Animator<SpringAnimation<Self>> {
        var a = SpringAnimation(from: self, target: target, velocity: Self.zero)
        a.configuration = configuration
        let animator = AnimatorContext.shared.animate(a)
        animator.changed.observe({ (a) -> Void in
            callback(a.value)
        })
        return animator
    }
    
}
