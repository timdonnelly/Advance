/// `Simulation` simulates changes to a value over time, based on
/// a function that calculates acceleration after each time step.
///
/// Constant time steps are not guaranteed elsewhere in the framework. Due to
/// the nature of dynamic functions, however, it is desirable to maintain
/// a constant update interval for a dynamic simulation. `Simulation`
/// instances maintain their own internal time state. When `advance(elapsed:)
/// is called on an instance, it may run an arbitrary number of time steps
/// internally (and call the underlying function as needed) in order to "catch
/// up" to the outside time. It then uses linear interpolation to match the
/// internal state to the required external time in order to return the most
/// precise calculations.
struct Simulation<Value: VectorConvertible> {
    
    // The internal time step. 0.008 == 120fps (double the typical screen refresh
    // rate). The math required to solve most functions is easy for modern
    // CPUs, but it's worth experimenting with this value if solver calculations
    // ever become a performance bottleneck.
    fileprivate let tickTime: Double = 0.008
    
    /// The function driving the simulation.
    private var function: AnySimulationFunction<Value> {
        didSet {
            // If the function changes, we need to make sure that its new state 
            // will allow the simulation to converge.
            hasConverged = false
            convergeIfPossible()
        }
    }
    
    // Tracks the delta between external and internal time.
    fileprivate var timeAccumulator: Double = 0.0
    
    /// Returns `true` if the solver has converged and does not currently
    /// need to be advanced on each frame.
    fileprivate (set) var hasConverged: Bool = false
    
    // The current state of the solver.
    private var current: (value: Value.VectorType, velocity: Value.VectorType)
    
    // The latest interpolated state that we use to return values to the outside
    // world.
    private var interpolated: (value: Value.VectorType, velocity: Value.VectorType)
    
    /// Creates a new `DynamicSolver` instance.
    ///
    /// - parameter function: The function that will drive the simulation.
    /// - parameter value: The initial value of the simulation.
    /// - parameter velocity: The initial velocity of the simulation.
    init<T>(function: T, initialValue: Value, initialVelocity: Value = .zero) where T: SimulationFunction, T.Value == Value {
        self.function = AnySimulationFunction(function)
        current = (value: initialValue.vector, velocity: initialVelocity.vector)
        interpolated = current
        convergeIfPossible()
    }
    
    fileprivate mutating func convergeIfPossible() {
        guard hasConverged == false else { return }
        
        switch function.convergence(value: current.value, velocity: current.velocity) {
        case .keepRunning:
            break
        case .converge(let convergedValue):
            current.value = convergedValue
            current.velocity = .zero
            interpolated = current
            hasConverged = true
        }

    }
    
    mutating func use<T>(function: T) where T: SimulationFunction, T.Value == Value {
        self.function = AnySimulationFunction(function)
    }
    
    /// Advances the simulation.
    ///
    /// - parameter elapsed: The duration by which to advance the simulation
    ///   in seconds.
    mutating func advance(by time: Double) {
        guard hasConverged == false else { return }
        
        // Limit to 10 physics ticks per update, should never come close.
        let t = min(time, tickTime * 10.0)
        
        // Add the new time to the accumulator. This can be thought of as the
        // delta between the time of the current physics state, and the time
        // that we need to solve for. When it is positive, we need to advance
        // the simulation to catch up.
        timeAccumulator += t
        
        var previous = current
        
        // Advance the simulation until the time accumulator is negative –
        // this means that the current state is ahead of the needed time.
        while timeAccumulator > 0.0 {
            if hasConverged {
                break
            }
            previous = current
            current = function.integrate(value: current.value, velocity: current.velocity, time: tickTime)
            timeAccumulator -= tickTime
        }
        
        assert(timeAccumulator <= 0.0)
        assert(timeAccumulator > -tickTime)
        
        // If convergence is possible, we can just do that and avoid interpolation.
        convergeIfPossible()
        
        if hasConverged == false {
            // The simulation did not converge. At this point, the latest state
            // was calculated for some time in the future of what we need
            // to satisfy `elapsed`. We can figure out the alpha in between
            // `previousState` and `simulationState`, and interpolate. This
            // will let us provide a more accurate value to the outside world,
            // while maintaining a consistent time step internally.
            let alpha = Double((tickTime + timeAccumulator) / tickTime)
            interpolated.value = interpolate(from: previous.value, to: current.value, alpha: alpha)
            interpolated.velocity = interpolate(from: previous.velocity, to: current.velocity, alpha: alpha)
        }
    }
    
    /// The current value.
    var value: Value {
        get { return Value(vector: interpolated.value) }
        set {
            interpolated.value = newValue.vector
            current.value = newValue.vector
            hasConverged = false
            convergeIfPossible()
        }
    }
    
    /// The current velocity.
    var velocity: Value {
        get { return Value(vector: interpolated.velocity) }
        set {
            interpolated.velocity = newValue.vector
            current.velocity = newValue.vector
            hasConverged = false
            convergeIfPossible()
        }
    }
}


fileprivate struct AnySimulationFunction<Value>: SimulationFunction where Value: VectorConvertible {
    
    private let _acceleration: (Value.VectorType, Value.VectorType) -> Value.VectorType
    private let _convergence: (Value.VectorType, Value.VectorType) -> Convergence<Value>
    
    public init<T: SimulationFunction>(_ wrapped: T) where T.Value == Value {
        _acceleration = wrapped.acceleration
        _convergence = wrapped.convergence
    }
    
    public func acceleration(value: Value.VectorType, velocity: Value.VectorType) -> Value.VectorType {
        return _acceleration(value, velocity)
    }
    
    public func convergence(value: Value.VectorType, velocity: Value.VectorType) -> Convergence<Value> {
        return _convergence(value, velocity)
    }
    
}

