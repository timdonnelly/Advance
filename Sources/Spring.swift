/// A specialized simulator that uses a spring function.
///
/// ```
/// let spring = Spring(value: CGPoint.zero)
/// spring.target = CGPoint(x: 300, y: 200)
///
/// ```
public final class Spring<Value: VectorConvertible> {
    
    public var onChange: ((Value) -> Void)? {
        get { return simulator.onChange }
        set { simulator.onChange = newValue }
    }
    
    private let simulator: Simulator<Value>
    
    private var function: SpringFunction<Value> {
        didSet {
            simulator.use(function: function)
        }
    }
    
    /// Initializes a new spring converged at the given value, using default configuration options for the spring function.
    public init(initialValue: Value) {
        function = SpringFunction(target: initialValue)
        simulator = Simulator(function: function, initialValue: initialValue)
    }
    
    public var value: Value {
        get { return simulator.value }
        set { simulator.value = newValue }
    }
    
    public var velocity: Value {
        get { return simulator.velocity }
        set { simulator.velocity = newValue }
    }
    
    /// The spring's target.
    public var target: Value {
        get { return function.target }
        set { function.target = newValue }
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    /// - Parameter value: The new value that the spring will be reset to.
    public func reset(to value: Value) {
        function.target = value
        simulator.value = value
        simulator.velocity = .zero
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

