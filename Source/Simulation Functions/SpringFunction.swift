import Foundation


/// Implements a simple spring acceleration function.
public struct SpringFunction<T>: SimulationFunction where T: Vector {
    
    /// The target of the spring.
    public var target: T
    
    /// Strength of the spring.
    public var tension: Scalar
    
    /// How damped the spring is.
    public var damping: Scalar
    
    /// The minimum scalar distance used for settling the spring simulation.
    public var threshold: Scalar
    
    /// Creates a new `SpringFunction` instance.
    ///
    /// - parameter target: The target of the new instance.
    public init(target: T = T.zero) {
        self.target = target
        self.tension = 120.0
        self.damping = 12.0
        self.threshold = 0.1
    }
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(for state: SimulationState<T>) -> T {
        let delta = state.value - target
        let accel = (-tension * delta) - (damping * state.velocity)
        return accel
    }
    
    public func convergence(for state: SimulationState<T>) -> Convergence<T> {
        let min = T(scalar: -threshold)
        let max = T(scalar: threshold)
        
        if state.velocity.clamped(min: min, max: max) != state.velocity {
            return .keepRunning
        }
        
        let valueDelta = state.value - target
        if valueDelta.clamped(min: min, max: max) != valueDelta {
            return .keepRunning
        }
        
        return .converge(atValue: target)
    }
    
}


public extension Animator {
    
    /// Starts a spring animation with the given properties, adopting the property's
    /// current velocity as `initialVelocity`.
    @discardableResult
    public func spring(to target: Value, tension: Scalar = 30.0, damping: Scalar = 5.0, threshold: Scalar = 0.1) -> AnimationRunner<Value> {
        return self.spring(to: target, initialVelocity: velocity, tension: tension, damping: damping, threshold: threshold)
    }
    
    /// Starts a spring animation with the given properties.
    @discardableResult
    public func spring(to target: Value, initialVelocity: Value, tension: Scalar = 30.0, damping: Scalar = 5.0, threshold: Scalar = 0.1) -> AnimationRunner<Value> {
        let animation = value
            .springAnimation(
                to: target,
                initialVelocity: initialVelocity,
                tension: tension,
                damping: damping,
                threshold: threshold)
        
        return self.animate(with: animation)
    }

}


public extension VectorConvertible {
    
    /// Returns a spring animation with the given properties.
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
