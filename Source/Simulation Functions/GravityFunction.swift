import simd

/// Implements a two-dimensional gravity simulation function.
public struct GravityFunction: SimulationFunction {
    
    /// The point that the value will be pulled toward.
    public var target: Vector2
    
    /// The minimum distance from target for which acceleration will be calculated. Larger values avoid dramatic
    /// slingshot effects when the value makes a pass near the target value.
    public var minRadius: Scalar = 30.0
    
    /// The minimum distance from the target that the value must be in order for the simulation to converge.
    public var threshold: Scalar = 0.1
    
    /// Initializes a new gravity function with the given target.
    public init(target: Vector2) {
        self.target = target
    }
    
    public func acceleration(for state: SimulationState<Vector2>) -> Vector2 {
        
        let delta = target - state.value
        let heading = atan2(delta.y, delta.x)
        
        var distance = hypot(delta.x, delta.y)
        distance = max(distance, minRadius)
        
        let accel = 1000000.0 / (distance*distance)
        
        var result = Vector2.zero
        result.x = accel * cos(heading)
        result.y = accel * sin(heading)
        return result
    }
    
    public func convergence(for state: SimulationState<Vector2>) -> Convergence<Vector2> {
        
        let min = Vector2(scalar: -threshold)
        let max = Vector2(scalar: threshold)
        
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
