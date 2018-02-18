import simd

public struct GravityFunction: SimulationFunction {
    
    public var target: Vector2
    
    public var minRadius: Scalar = 30.0
    
    public var threshold: Scalar = 0.1
    
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
    
    public func status(for state: SimulationState<Vector2>) -> SimulationResult<Vector2> {
        
        let min = Vector2(scalar: -threshold)
        let max = Vector2(scalar: threshold)
        
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