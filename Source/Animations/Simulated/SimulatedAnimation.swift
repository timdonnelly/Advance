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

public extension KeyPathAnimatable {
    
    @discardableResult
    public func spring<T>(keyPath: ReferenceWritableKeyPath<Self, T>, to target: T, initialVelocity: T = .zero, tension: Scalar = 30.0, damping: Scalar = 5.0, threshold: Scalar = 0.1) -> Animator<T> where T: VectorConvertible {
        return self[keyPath: keyPath]
            .springAnimation(
                to: target,
                initialVelocity: initialVelocity,
                tension: tension,
                damping: damping,
                threshold: threshold)
            .run()
            .bound(to: self, keyPath: keyPath)
    }
    
    @discardableResult
    public func decay<T>(keyPath: ReferenceWritableKeyPath<Self, T>, initialVelocity: T, drag: Scalar = 3.0, threshold: Scalar = 0.1) -> Animator<T> where T: VectorConvertible {
        return self[keyPath: keyPath]
            .decayAnimation(
                initialVelocity: initialVelocity,
                drag: drag,
                threshold: threshold)
            .run()
            .bound(to: self, keyPath: keyPath)
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
    
    public func decayAnimation(initialVelocity: Self, drag: Scalar = 3.0, threshold: Scalar = 0.1) -> SimulatedAnimation<Self, DecayFunction<Self.VectorType>> {
        var function = DecayFunction<Self.VectorType>()
        function.drag = drag
        function.threshold = threshold
        return SimulatedAnimation(function: function, value: self, velocity: initialVelocity)
    }
    
}
