import SwiftUI

/// Gradually reduces velocity until it equals `Vector.zero`.
public struct DecayFunction<T>: SimulationFunction where T: Animatable {
    
    /// How close to 0 each component of the velocity must be before the
    /// simulation is allowed to converge.
    public var threshold: Double
    
    /// How much to erode the velocity.
    public var drag: Double
    
    /// Creates a new `DecayFunction` instance.
    public init(threshold: Double = 0.1, drag: Double = 3.0) {
        self.threshold = threshold
        self.drag = drag
    }
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(value: T.AnimatableData, velocity: T.AnimatableData) -> T.AnimatableData {
        var accel = velocity
        accel.scale(by: -drag)
        return accel
    }
    
    public func convergence(value: T.AnimatableData, velocity: T.AnimatableData) -> Convergence<T> {
        if velocity.magnitudeSquared < threshold*threshold {
            return .converge(atValue: value)
        } else {
            return .keepRunning
        }
    }
    
}
