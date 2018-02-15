import Foundation
import QuartzCore

/// The configuration options for a spring function.
public struct SpringConfiguration {
    
    /// Strength of the spring.
    public var tension: Scalar = 120.0
    
    /// How damped the spring is.
    public var damping: Scalar = 12.0
    
    /// The minimum scalar distance used for settling the spring simulation.
    public var threshold: Scalar = 0.1
    
    /// Creates a new `SpringConfiguration` instance with default values.
    public init() {}
}

/// Implements a simple spring acceleration function.
public struct SpringFunction<VectorType: Vector>: DynamicFunction {
    
    /// The target of the spring.
    public var target: VectorType
    
    /// Configuration options.
    public var configuration: SpringConfiguration
    
    /// Creates a new `SpringFunction` instance.
    ///
    /// - parameter target: The target of the new instance.
    public init(target: VectorType) {
        self.target = target
        self.configuration = SpringConfiguration()
    }
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(value: VectorType, velocity: VectorType) -> VectorType {
        let delta = value - target
        let accel = (-configuration.tension * delta) - (configuration.damping * velocity)
        return accel
    }
    
    /// Returns `true` if the simulation can become settled.
    public func canSettle(value: VectorType, velocity: VectorType) -> Bool {
        let min = VectorType(scalar: -configuration.threshold)
        let max = VectorType(scalar: configuration.threshold)
        
        if velocity.clamped(min: min, max: max) != velocity {
            return false
        }
        
        let valueDelta = value - target
        if valueDelta.clamped(min: min, max: max) != valueDelta {
            return false
        }
        
        return true
    }
    
    /// Returns the value to settle on.
    public func settledValue(value: VectorType, velocity: VectorType) -> VectorType {
        return target
    }
}
