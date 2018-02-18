public struct SimulatedAnimation<Result, T>: Animation where Result: VectorConvertible, T: SimulationFunction, Result.VectorType == T.VectorType {
    
    private var simulation: Simulation<T>
    
    public init(function: T, value: Result, velocity: Result) {
        self.simulation = Simulation(function: function, value: value.vector, velocity: velocity.vector)
    }
    
    public mutating func advance(by time: Double) {
        simulation.advance(by: time)
    }
    
    public var value: Result {
        return Result(vector: simulation.value)
    }
    
    public var isFinished: Bool {
        return simulation.settled
    }
    
}

public extension Animator {
    
    public convenience init<Result, F>(initialValue: Result, initialVelocity: Result, function: F) where T == SimulatedAnimation<Result, F> {
        let animation = SimulatedAnimation(function: function, value: initialValue, velocity: initialVelocity)
        self.init(animation: animation)
    }
    
}

public extension VectorConvertible {
    
    public func springAnimation(to target: Self, initialVelocity: Self = .zero, tension: Scalar = 30.0, damping: Scalar = 5.0, threshold: Scalar = 0.1) -> SimulatedAnimation<Self, SpringFunction<Self.VectorType>> {
        var function = SpringFunction(target: target.vector)
        function.tension = tension
        function.damping = damping
        function.threshold = threshold
        return SimulatedAnimation(
            function: function,
            value: self,
            velocity: initialVelocity)
    }
    
}
