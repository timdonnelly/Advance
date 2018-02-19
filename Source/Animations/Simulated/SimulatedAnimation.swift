public struct SimulatedAnimation<Element, T>: Animation where Element: VectorConvertible, T: SimulationFunction, Element.VectorType == T.VectorType {
    
    private var simulation: Simulation<T>
    
    public init(function: T, value: Element, velocity: Element) {
        self.simulation = Simulation(function: function, value: value.vector, velocity: velocity.vector)
    }
    
    public mutating func advance(by time: Double) {
        simulation.advance(by: time)
    }
    
    public var value: Element {
        return Element(vector: simulation.value)
    }
    
    public var isFinished: Bool {
        return simulation.hasConverged
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
