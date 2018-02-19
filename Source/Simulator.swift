/// Animates changes to a value using a simulation function.
///
/// In most scenarios, physics-based animations are simply run to completion.
/// For those situations, `Animator` and `PropertyAnimator` make it easy to
/// run and use the results of an animation.
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
/// Another difference between `Simulator` and the animator classes is that a
/// simulator never 'finishes.' Simulations may converge (reach a settled state),
/// but changes to either the function or the current simulation state may cause
/// the simulation to begin running again.
///
public class Simulator<Element, Function> where Element: VectorConvertible, Function: SimulationFunction, Element.VectorType == Function.VectorType {
    
    private let valueSink = Sink<Element>()
    
    private var simulation: Simulation<Function> {
        didSet {
            lastNotifiedValue = Element(vector: simulation.value)
            loop.paused = simulation.hasConverged
        }
    }
    
    private let loop: Loop
    
    /// The function driving the simulation.
    public var function: Function {
        get { return simulation.function }
        set { simulation.function = newValue }
    }
    
    private var lastNotifiedValue: Element {
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
    public init(function: Function, value: Element, velocity: Element = Element.zero) {
        simulation = Simulation(function: function, value: value.vector, velocity: velocity.vector)
        lastNotifiedValue = value
        loop = Loop()
        
        loop.observe { [unowned self] (frame) in
            self.simulation.advance(by: frame.duration)
        }

        loop.paused = simulation.hasConverged
    }
    
    /// The current value of the spring.
    public var value: Element {
        get { return Element(vector: simulation.value) }
        set { simulation.value = newValue.vector }
    }
    
    /// The current velocity of the simulation.
    public var velocity: Element {
        get { return Element(vector: simulation.velocity) }
        set { simulation.velocity = newValue.vector }
    }

}

extension Simulator: Observable {
    
    @discardableResult
    public func observe(_ observer: @escaping (Element) -> Void) -> Subscription {
        return valueSink.observe(observer)
    }
    
}

public extension Simulator where Function == SpringFunction<Element.VectorType> {
    
    public convenience init(value: Element) {
        let spring = SpringFunction(target: value.vector)
        self.init(function: spring, value: value)
    }
    
    /// The spring's target.
    public var target: Element {
        get { return Element(vector: function.target) }
        set { function.target = newValue.vector }
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    /// - Parameter value: The new value that the spring will be reset to.
    public func reset(to value: Element) {
        function.target = value.vector
        self.value = value
        self.velocity = Element.zero
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
public typealias Spring<T> = Simulator<T, SpringFunction<T.VectorType>> where T: VectorConvertible
