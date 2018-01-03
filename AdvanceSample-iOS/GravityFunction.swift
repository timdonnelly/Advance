import Advance
import Foundation

struct GravityFunction: DynamicFunction {
    
    typealias Vector = Vector2
    
    var target: Vector
    
    var minRadius = 30.0
    
    var threshold: Scalar = 0.1
    
    init(target: Vector) {
        self.target = target
    }
    
    func acceleration(value: Vector, velocity: Vector) -> Vector {
        
        let delta = target - value
        let heading = atan2(delta.y, delta.x)
        
        var distance = hypot(delta.x, delta.y)
        distance = max(distance, minRadius)
        
        let accel = 1000000.0 / (distance*distance)
        
        var result = Vector.zero
        result.x = accel * cos(heading)
        result.y = accel * sin(heading)
        return result
    }
    
    func canSettle(value: Vector, velocity: Vector) -> Bool {
        let min = Vector(scalar: -threshold)
        let max = Vector(scalar: threshold)
        
        if velocity.clamped(min: min, max: max) != velocity {
            return false
        }
        
        let valueDelta = value - target
        if valueDelta.clamped(min: min, max: max) != valueDelta {
            return false
        }
        
        return true
    }
    
    func settledValue(value: Vector, velocity: Vector) -> Vector {
        return target
    }
}
