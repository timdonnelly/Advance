/// A specialized simulator that uses a spring function.
///
/// ```
/// let spring = Spring(value: CGPoint.zero)
/// spring.target = CGPoint(x: 300, y: 200)
///
/// ```
public final class Spring<T: VectorConvertible>: Simulator<T, SpringFunction<T.VectorType>> {
    
    /// Initializes a new spring converged at the given value, using default configuration options for the spring function.
    public init(value: T) {
        let spring = SpringFunction(target: value.vector)
        super.init(function: spring, value: value, velocity: .zero)
    }
    
    /// The spring's target.
    public var target: T {
        get { return T(vector: function.target) }
        set { function.target = newValue.vector }
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    /// - Parameter value: The new value that the spring will be reset to.
    public func reset(to value: T) {
        function.target = value.vector
        self.value = value
        self.velocity = .zero
    }
    
    /// How strongly the spring will pull the value toward the target,
    public var tension: Double {
        get { return function.tension }
        set { function.tension = newValue }
    }
    
    /// The resistance that the spring encounters while moving the value.
    public var damping: Double {
        get { return function.damping }
        set { function.damping = newValue }
    }
    
    /// The minimum distance from the target value (for each component) that the
    /// current value can be in order to ender a converged (settled) state.
    public var threshold: Double {
        get { return function.threshold }
        set { function.threshold = newValue }
    }
    
}

