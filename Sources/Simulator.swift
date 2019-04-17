/// Animates changes to a value using a simulation function.
///
/// `Simulator` is useful for scenarios where you need direct access
/// to a running simulation. A `Simulator` instance provides mutable access to the
/// `function` property (containing the underlying function that is driving the
/// simulation), along with the current state of the simulation (value and
/// velocity).
public class Simulator<Function> where Function: SimulationFunction {
    
    public var onChange: ((Function.Value) -> Void)? = nil
    
    private let displayLink: DisplayLink
    
    public var function: Function {
        didSet {
            simulation.use(function: function)
        }
    }
    
    private var simulation: Simulation<Function.Value> {
        didSet {
            lastNotifiedValue = simulation.value
            displayLink.isPaused = simulation.hasConverged
        }
    }

    private var lastNotifiedValue: Function.Value {
        didSet {
            guard lastNotifiedValue != oldValue else { return }
            onChange?(lastNotifiedValue)
        }
    }
    
    /// Creates a new `Simulator` instance
    ///
    /// - parameter function: The function that will drive the simulation.
    /// - parameter value: The initial value of the simulation.
    /// - parameter velocity: The initial velocity of the simulation.
    public init(function: Function, initialValue: Function.Value, initialVelocity: Function.Value = Function.Value.zero) {
        self.function = function
        simulation = Simulation(function: function, initialValue: initialValue, initialVelocity: initialVelocity)
        lastNotifiedValue = initialValue
        displayLink = DisplayLink()
        
        displayLink.onFrame = { [unowned self] (frame) in
            self.simulation.advance(by: frame.duration)
        }

        displayLink.isPaused = simulation.hasConverged
    }
    
    /// The current value of the spring.
    public final var value: Function.Value {
        get { return simulation.value }
        set { simulation.value = newValue }
    }
    
    /// The current velocity of the simulation.
    public final var velocity: Function.Value {
        get { return simulation.velocity }
        set { simulation.velocity = newValue }
    }

}
