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
    
    private let displayLink: DisplayLink
    
    fileprivate let valueSink = Sink<Value>()
    
    private var simulation: SimulationState<Function> {
        didSet {
            lastNotifiedValue = Value(vector: simulation.value)
            displayLink.isPaused = simulation.hasConverged
        }
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
        simulation = SimulationState(function: function, value: value.vector, velocity: velocity.vector)
        lastNotifiedValue = value
        displayLink = DisplayLink()
        
        displayLink.onFrame = { [unowned self] (frame) in
            self.simulation.advance(by: frame.duration)
        }

        displayLink.isPaused = simulation.hasConverged
    }
    
    /// The function driving the simulation.
    public final var function: Function {
        get { return simulation.function }
        set { simulation.function = newValue }
    }
    
    /// The current value of the spring.
    public final var value: Value {
        get { return Value(vector: simulation.value) }
        set { simulation.value = newValue.vector }
    }
    
    /// The current velocity of the simulation.
    public final var velocity: Value {
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
