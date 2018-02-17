import Advance
import CoreGraphics
import Foundation


struct GravityFunction: Simulation {
    
    var target: CGPoint
    
    var minRadius: CGFloat = 30.0
    
    var threshold: Scalar = 0.1
    
    init(target: CGPoint) {
        self.target = target
    }
    
    func acceleration(for state: SimulationState<CGPoint>) -> CGPoint {
        
        let delta = target - state.value
        let heading = atan2(delta.y, delta.x)
        
        var distance = hypot(delta.x, delta.y)
        distance = max(distance, minRadius)
        
        let accel = 1000000.0 / (distance*distance)
        
        var result = CGPoint.zero
        result.x = accel * cos(heading)
        result.y = accel * sin(heading)
        return result
    }
    
    func status(for state: SimulationState<CGPoint>) -> SimulationResult<CGPoint> {
        
        let min = CGPoint(scalar: -threshold)
        let max = CGPoint(scalar: threshold)
        
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
