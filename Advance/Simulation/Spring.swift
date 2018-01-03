/// Animates changes to a value using spring physics.
///
/// Instances of `Spring` should be used in situations where spring physics
/// are the only animation type required, or when convenient access to the
/// properties of a running spring simulation is needed.
///
/// The focused API of this class makes it more convenient in such cases
/// than using an `Animatable` instance, where a new spring animation would
/// have to be added each time the spring needed to be modified.
///
/// ```
/// let s = Spring(value: CGPoint.zero)
///
/// s.changed.observe { (value) in
///   // do something with the value when it changes
/// }
///
/// s.target = CGPoint(x: 100.0, y: 200.0)
/// // Off it goes!
/// ```
public final class Spring<Value: VectorConvertible> {
    
    fileprivate var solver: DynamicSolver<SpringFunction<Value.VectorType>> {
        didSet {
            lastNotifiedValue = Value(vector: solver.value)
            if solver.settled == false && subscription.paused == true {
                subscription.paused = false
            }
        }
    }
    
    fileprivate lazy var subscription: Loop.Subscription = {
        let s = Loop.shared.subscribe()
        
        s.advanced.observe({ [unowned self] (elapsed) -> Void in
            self.solver.advance(by: elapsed)
            if self.solver.settled {
                self.subscription.paused = true
            }
        })
        
        return s
    }()
    
    /// Fires when `value` has changed.
    public let changed = Observable<Value>()
    
    fileprivate var lastNotifiedValue: Value {
        didSet {
            guard lastNotifiedValue != oldValue else { return }
            changed.send(value: lastNotifiedValue)
        }
    }
    
    /// Creates a new `Spring` instance
    ///
    /// - parameter value: The initial value of the spring. The spring will be
    ///   initialized with `target` and `value` equal to the given value, and
    ///   a velocity of `0`.
    public init(value: Value) {
        let f = SpringFunction(target: value.vector)
        solver = DynamicSolver(function: f, value: value.vector)
        lastNotifiedValue = value
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    public func reset(to value: Value) {
        var f = solver.function
        f.target = value.vector
        solver = DynamicSolver(function: f, value: value.vector)
        lastNotifiedValue = value
    }
    
    /// The current value of the spring.
    public var value: Value {
        get { return Value(vector: solver.value) }
        set { solver.value = newValue.vector }
    }
    
    /// The current velocity of the simulation.
    public var velocity: Value {
        get { return Value(vector: solver.velocity) }
        set { solver.velocity = newValue.vector }
    }
    
    /// The target value of the spring. As the simulation runs, `value` will be 
    /// pulled toward this value.
    public var target: Value {
        get { return Value(vector: solver.function.target) }
        set { solver.function.target = newValue.vector }
    }
    
    /// Configuration options for the spring.
    public var configuration: SpringConfiguration {
        get { return solver.function.configuration }
        set { solver.function.configuration = newValue }
    }
}
