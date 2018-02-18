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


public class Animator<Result, Function> where Function: SimulationFunction, Result == Function.Result {
    
    private let changedSink = Sink<Result>()
    
    public var simulation: Simulation<Function> {
        didSet {
            lastNotifiedValue = simulation.value
            subscription.paused = simulation.settled
        }
    }
    
    private let subscription: Loop.Subscription
    
    /// Fires when `value` has changed.
    public var changed: Observable<Result> {
        return changedSink.observable
    }
    
    fileprivate var lastNotifiedValue: Result {
        didSet {
            guard lastNotifiedValue != oldValue else { return }
            changedSink.send(value: lastNotifiedValue)
        }
    }
    
    /// Creates a new `Spring` instance
    ///
    /// - parameter value: The initial value of the spring. The spring will be
    ///   initialized with `target` and `value` equal to the given value, and
    ///   a velocity of `0`.
    public init(function: Function, value: Result) {
        simulation = Simulation(function: function, value: value)
        lastNotifiedValue = value
        subscription = Loop.shared.subscribe()
        
        subscription.advanced.observe({ [unowned self] (elapsed) -> Void in
            self.simulation.advance(by: elapsed)
            if self.simulation.settled {
                self.subscription.paused = true
            }
        })
        
        subscription.paused = simulation.settled
    }
    
    /// The current value of the spring.
    public var value: Result {
        get { return simulation.value }
        set { simulation.value = newValue }
    }
    
    /// The current velocity of the simulation.
    public var velocity: Result {
        get { return simulation.velocity }
        set { simulation.velocity = newValue }
    }

}

public extension Animator where Function == SpringFunction<Result> {
    
    public convenience init(value: Result) {
        let spring = SpringFunction(target: value)
        self.init(function: spring, value: value)
    }
    
    public var target: Result {
        get { return simulation.function.target }
        set { simulation.function.target = newValue }
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    public func reset(to value: Result) {
        var f = simulation.function
        f.target = value
        simulation = Simulation(function: f, value: value)
        lastNotifiedValue = value
    }
    
    public var tension: Scalar {
        get { return simulation.function.tension }
        set { simulation.function.tension = newValue }
    }
    
    public var damping: Scalar {
        get { return simulation.function.damping }
        set { simulation.function.damping = newValue }
    }
    
    public var threshold: Scalar {
        get { return simulation.function.threshold }
        set { simulation.function.threshold = newValue }
    }
    
}

public typealias Spring<T> = Animator<T, SpringFunction<T>> where T: VectorConvertible
