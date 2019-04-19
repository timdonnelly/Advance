/// Animates values using a spring function.
///
/// ```
/// let spring = Spring(value: CGPoint.zero)
/// spring.target = CGPoint(x: 300, y: 200)
///
/// ```
public final class Spring<Value: VectorConvertible> {
    
    private let animator: Animator<Value>
    
    private var function: SpringFunction<Value>
    
    /// Initializes a new spring converged at the given value, using default configuration options for the spring function.
    public init(initialValue: Value) {
        function = SpringFunction(target: initialValue)
        animator = Animator(initialValue: initialValue)
    }
    
    public var onChange: ((Value) -> Void)? {
        get { return animator.onChange }
        set { animator.onChange = newValue }
    }
    
    public var value: Value {
        get { return animator.value }
        set {
            let velocity = animator.velocity
            animator.value = newValue
            applyFunction(impartingVelocity: velocity)
        }
    }
    
    public var velocity: Value {
        get { return animator.velocity }
        set { applyFunction(impartingVelocity: newValue) }
    }
    
    /// The spring's target.
    public var target: Value {
        get { return function.target }
        set {
            function.target = newValue
            applyFunction()
        }
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    /// - Parameter value: The new value that the spring will be reset to.
    public func reset(to value: Value) {
        function.target = value
        animator.value = value
    }
    
    /// How strongly the spring will pull the value toward the target,
    public var tension: Double {
        get { return function.tension }
        set {
            function.tension = newValue
            applyFunction()
        }
    }
    
    /// The resistance that the spring encounters while moving the value.
    public var damping: Double {
        get { return function.damping }
        set {
            function.damping = newValue
            applyFunction()
        }
    }
    
    /// The minimum distance from the target value (for each component) that the
    /// current value can be in order to enter a converged (settled) state.
    public var threshold: Double {
        get { return function.threshold }
        set {
            function.threshold = newValue
            applyFunction()
        }
    }
    
    private func applyFunction(impartingVelocity velocity: Value? = nil) {
        if let velocity = velocity {
            animator.simulate(using: function, initialVelocity: velocity)
        } else {
            animator.simulate(using: function)
        }
    }
    
}

