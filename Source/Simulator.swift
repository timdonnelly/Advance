/// Animates changes to a value using a simulation function.
public class Simulator<Result, Function> where Result: VectorConvertible, Function: SimulationFunction, Result.VectorType == Function.VectorType {
    
    private let valueSink = Sink<Result>()
    
    private var simulation: Simulation<Function> {
        didSet {
            lastNotifiedValue = Result(vector: simulation.value)
            loop.paused = simulation.hasConverged
        }
    }
    
    private let loop: Loop
    
    /// The function driving the simulation.
    public var function: Function {
        get { return simulation.function }
        set { simulation.function = newValue }
    }
    
    fileprivate var lastNotifiedValue: Result {
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
    public init(function: Function, value: Result, velocity: Result = Result.zero) {
        simulation = Simulation(function: function, value: value.vector, velocity: velocity.vector)
        lastNotifiedValue = value
        loop = Loop()
        
        loop.observe { [unowned self] (frame) in
            self.simulation.advance(by: frame.duration)
        }

        loop.paused = simulation.hasConverged
    }
    
    /// The current value of the spring.
    public var value: Result {
        get { return Result(vector: simulation.value) }
        set { simulation.value = newValue.vector }
    }
    
    /// The current velocity of the simulation.
    public var velocity: Result {
        get { return Result(vector: simulation.velocity) }
        set { simulation.velocity = newValue.vector }
    }

}

extension Simulator: Observable {
    
    @discardableResult
    public func observe(_ observer: @escaping (Result) -> Void) -> Subscription {
        return valueSink.observe(observer)
    }
    
}

public extension Simulator where Function == SpringFunction<Result.VectorType> {
    
    public convenience init(value: Result) {
        let spring = SpringFunction(target: value.vector)
        self.init(function: spring, value: value)
    }
    
    /// The spring's target.
    public var target: Result {
        get { return Result(vector: function.target) }
        set { function.target = newValue.vector }
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    public func reset(to value: Result) {
        function.target = value.vector
        self.value = value
        self.velocity = Result.zero
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
