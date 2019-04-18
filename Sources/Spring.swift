/// Animates values using a spring function.
///
/// ```
/// let spring = Spring(value: CGPoint.zero)
/// spring.target = CGPoint(x: 300, y: 200)
///
/// ```
public final class Spring<Value: VectorConvertible> {
    
    private let displayLink = DisplayLink()
    
    private var function: SpringFunction<Value> {
        didSet {
            simulation.use(function: function)
        }
    }
    
    private var simulation: Simulation<Value> {
        didSet {
            displayLink.isPaused = simulation.hasConverged
            if simulation.value != oldValue.value {
                onChange?(simulation.value)
            }
        }
    }
    
    /// Initializes a new spring converged at the given value, using default configuration options for the spring function.
    public init(initialValue: Value) {
        function = SpringFunction(target: initialValue)
        simulation = Simulation(function: function, initialValue: initialValue)
        displayLink.onFrame = { [weak self] frame in
            self?.simulation.advance(by: frame.duration)
        }
    }
    
    public var onChange: ((Value) -> Void)?
    
    public var value: Value {
        get { return simulation.value }
        set { simulation.value = newValue }
    }
    
    public var velocity: Value {
        get { return simulation.velocity }
        set { simulation.velocity = newValue }
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
        simulation.value = value
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
    /// current value can be in order to enter a converged (settled) state.
    public var threshold: Double {
        get { return function.threshold }
        set { function.threshold = newValue }
    }
    
}

