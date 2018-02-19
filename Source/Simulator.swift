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
    
    public var function: Function {
        get { return simulation.function }
        set { simulation.function = newValue }
    }
    
    /// Observable stream of values from the simulation.
    public var values: Observable<Result> {
        return valueSink.observable
    }
    
    fileprivate var lastNotifiedValue: Result {
        didSet {
            guard lastNotifiedValue != oldValue else { return }
            valueSink.send(value: lastNotifiedValue)
        }
    }
    
    /// Creates a new `Spring` instance
    ///
    /// - parameter value: The initial value of the spring. The spring will be
    ///   initialized with `target` and `value` equal to the given value, and
    ///   a velocity of `0`.
    public init(function: Function, value: Result) {
        simulation = Simulation(function: function, value: value.vector)
        lastNotifiedValue = value
        loop = Loop()
        
        loop.frames.observe { [unowned self] (frame) in
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

public final class Spring<Result>: Simulator<Result, SpringFunction<Result.VectorType>> where Result: VectorConvertible {
    
    public init(value: Result) {
        let spring = SpringFunction(target: value.vector)
        super.init(function: spring, value: value)
    }
    
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
    
    public var tension: Scalar {
        get { return function.tension }
        set { function.tension = newValue }
    }
    
    public var damping: Scalar {
        get { return function.damping }
        set { function.damping = newValue }
    }
    
    public var threshold: Scalar {
        get { return function.threshold }
        set { function.threshold = newValue }
    }
    
}
