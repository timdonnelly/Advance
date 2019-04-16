import Foundation


/// Implements a simple spring acceleration function.
public struct SpringFunction<T>: SimulationFunction where T: SIMD, T.Scalar == Double {
    
    /// The target of the spring.
    public var target: T
    
    /// Strength of the spring.
    public var tension: Double
    
    /// How damped the spring is.
    public var damping: Double
    
    /// The minimum Double distance used for settling the spring simulation.
    public var threshold: Double
    
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
    public func acceleration(value: T, velocity: T) -> T {
        let delta = value - target
        let accel = (-tension * delta) - (damping * velocity)
        return accel
    }
    
    public func convergence(value: T, velocity: T) -> Convergence<T> {
        let min = T(repeating: -threshold)
        let max = T(repeating: threshold)
        
        if velocity.clamped(min: min, max: max) != velocity {
            return .keepRunning
        }
        
        let valueDelta = value - target
        if valueDelta.clamped(min: min, max: max) != valueDelta {
            return .keepRunning
        }
        
        return .converge(atValue: target)
    }
    
}
