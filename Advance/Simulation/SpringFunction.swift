import Foundation
import QuartzCore


/// Implements a simple spring acceleration function.
public struct SpringFunction<T>: SimulationFunction where T: VectorConvertible {
    
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
    
    public func status(for state: SimulationState<T>) -> SimulationResult<T> {
        let min = T(scalar: -threshold)
        let max = T(scalar: threshold)
        
        if state.velocity.clamped(min: min, max: max) != state.velocity {
            return .running
        }
        
        let valueDelta = state.value - target
        if valueDelta.clamped(min: min, max: max) != valueDelta {
            return .running
        }
        
        return .settled(value: target)
    }
    
}
