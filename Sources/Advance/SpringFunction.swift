import SwiftUI

/// Implements a simple spring acceleration function.
public struct SpringFunction<T>: SimulationFunction where T: Animatable {
    
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
    public init(target: T, tension: Double = 120.0, damping: Double = 12.0, threshold: Double = 0.1) {
        self.target = target
        self.tension = tension
        self.damping = damping
        self.threshold = threshold
    }
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(value: T.AnimatableData, velocity: T.AnimatableData) -> T.AnimatableData {
        let delta = value - target.animatableData
        
        var deltaAccel = delta
        deltaAccel.scale(by: -tension)
        
        var dampingAccel = velocity
        dampingAccel.scale(by: damping)
        
        return deltaAccel - dampingAccel
    }
    
    public func convergence(value: T.AnimatableData, velocity: T.AnimatableData) -> Convergence<T> {
        if velocity.magnitudeSquared > threshold*threshold {
            return .keepRunning
        }
        
        let valueDelta = value - target.animatableData
        if valueDelta.magnitudeSquared > threshold*threshold {
            return .keepRunning
        }
        
        return .converge(atValue: target.animatableData)
    }
    
}
