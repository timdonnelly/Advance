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
public struct SpringFunction<VectorType>: Simulation where VectorType: Vector {
    
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
    public func acceleration(for state: SimulationState<VectorType>) -> VectorType {
        let delta = state.value - target
        let accel = (-configuration.tension * delta) - (configuration.damping * state.velocity)
        return accel
    }
    
    public func status(for state: SimulationState<VectorType>) -> SimulationStatus<VectorType> {
        let min = VectorType(scalar: -configuration.threshold)
        let max = VectorType(scalar: configuration.threshold)
        
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
