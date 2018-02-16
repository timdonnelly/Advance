/// RK4 Integration.
public extension DynamicsState {
    
    public mutating func integrate<F>(function: F, time: Double) where F: AccelerationFunction, F.VectorType == T {
        self = integrating(function: function, time: time)
    }
    
    public func integrating<F>(function: F, time: Double) -> DynamicsState<T> where F: AccelerationFunction, F.VectorType == T {
        
        let initial = Derivative(value:F.VectorType.zero, velocity: F.VectorType.zero)
        
        let a = evaluate(function: function, time: 0.0, derivative: initial)
        let b = evaluate(function: function, time: time * 0.5, derivative: a)
        let c = evaluate(function: function, time: time * 0.5, derivative: b)
        let d = evaluate(function: function, time: time, derivative: c)
        
        var dxdt = a.value
        dxdt += (2.0 * (b.value + c.value)) + d.value
        dxdt = Scalar(1.0/6.0) * dxdt
        
        var dvdt = a.velocity
        dvdt += (2.0 * (b.velocity + c.velocity)) + d.velocity
        dvdt = Scalar(1.0/6.0) * dvdt
        
        
        let val = value + Scalar(time) * dxdt
        let vel = velocity + Scalar(time) * dvdt
        
        return DynamicsState(value: val, velocity: vel)
    }
    
    private func evaluate<F>(function: F, time: Double, derivative: Derivative) -> Derivative where F: AccelerationFunction, F.VectorType == T {
        let val = value + Scalar(time) * derivative.value
        let vel = velocity + Scalar(time) * derivative.velocity
        let accel = function.acceleration(value: val, velocity: vel)
        let d = Derivative(value: vel, velocity: accel)
        return d
    }
    
    
    private struct Derivative {
        var value: T
        var velocity: T
    }
    
}
