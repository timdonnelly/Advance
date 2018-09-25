/// Animates changes to a value using a simulation function.
///
/// In most scenarios, physics-based animations are simply run to completion.
/// For those situations, `Animator` makes it easy to run and use the results of
/// an animation.
///
/// In contrast, `Simulator` is useful for scenarios where you need direct access
/// to a running simulation. This might occur in a UI where the user's scroll
/// position drives changes to a spring's tension, for example. It would be
/// impractical to create and start a new animation every time the simulation
/// needs to change. A `Simulator` instance provides mutable access to the
/// `function` property (containing the underlying function that is driving the
/// simulation), along with the current state of the simulation (value and
/// velocity).
///
public class Simulator<Value, Function> where Value: VectorConvertible, Function: SimulationFunction, Value.VectorType == Function.VectorType {
    
    fileprivate let valueSink = Sink<Value>()
    
    private var simulation: Simulation<Function> {
        didSet {
            lastNotifiedValue = Value(vector: simulation.value)
            loop.paused = simulation.hasConverged
        }
    }
    
    private let loop: Loop
    
    /// The function driving the simulation.
    public var function: Function {
        get { return simulation.function }
        set { simulation.function = newValue }
    }
    
    private var lastNotifiedValue: Value {
        didSet {
            guard lastNotifiedValue != oldValue else { return }
            valueSink.send(value: lastNotifiedValue)
        }
    }
    
    /// Creates a new `Simulator` instance
    ///
    /// - parameter function: The function that will drive the simulation.
    /// - parameter value: The initial value of the simulation.
    /// - parameter velocity: The initial velocity of the simulation.
    public init(function: Function, value: Value, velocity: Value = Value.zero) {
        simulation = Simulation(function: function, value: value.vector, velocity: velocity.vector)
        lastNotifiedValue = value
        loop = Loop()
        
        loop.observe { [unowned self] (frame) in
            self.simulation.advance(by: frame.duration)
        }

        loop.paused = simulation.hasConverged
    }
    
    /// The current value of the spring.
    public var value: Value {
        get { return Value(vector: simulation.value) }
        set { simulation.value = newValue.vector }
    }
    
    /// The current velocity of the simulation.
    public var velocity: Value {
        get { return Value(vector: simulation.velocity) }
        set { simulation.velocity = newValue.vector }
    }

}

extension Simulator: Observable {
    
    @discardableResult
    public func observe(_ observer: @escaping (Value) -> Void) -> Subscription {
        return valueSink.observe(observer)
    }
    
}

public extension Simulator where Function == SpringFunction<Value.VectorType> {
    
    /// Initializes a new spring converged at the given value, using default configuration options for the spring function.
    public convenience init(value: Value) {
        let spring = SpringFunction(target: value.vector)
        self.init(function: spring, value: value)
    }
    
    /// Initializes a new spring converged at the value returned by `object[keyPath: keyPath`, and bound to the given
    /// object and key path.
    public convenience init<T>(boundTo object: T, keyPath: ReferenceWritableKeyPath<T, Value>) {
        let initialValue = object[keyPath: keyPath]
        self.init(value: initialValue)
        bind(to: object, keyPath: keyPath)
    }
    
    /// The spring's target.
    public var target: Value {
        get { return Value(vector: function.target) }
        set { function.target = newValue.vector }
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    /// - Parameter value: The new value that the spring will be reset to.
    public func reset(to value: Value) {
        function.target = value.vector
        self.value = value
        self.velocity = Value.zero
    }
    
    /// How strongly the spring will pull the value toward the target,
    public var tension: Scalar {
        get { return function.tension }
        set { function.tension = newValue }
    }
    
    /// The resistance that the spring encounters while moving the value.
    public var damping: Scalar {
        get { return function.damping }
        set { function.damping = newValue }
    }
    
    /// The minimum distance from the target value (for each component) that the
    /// current value can be in order to ender a converged (settled) state.
    public var threshold: Scalar {
        get { return function.threshold }
        set { function.threshold = newValue }
    }
    
}

/// A specialized simulator that uses a spring function.
///
/// ```
/// let spring = Spring(value: CGPoint.zero)
/// spring.bind(to: view, keyPath: \.center)
/// spring.target = CGPoint(x: 300, y: 200)
///
/// ```
public typealias Spring<T> = Simulator<T, SpringFunction<T.VectorType>> where T: VectorConvertible
