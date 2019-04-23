/// [The RK4 method](https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods)
/// is used to integrate the acceleration function.
extension SimulationFunction {
    
    private typealias Derivative = (value: Value.VectorType, velocity: Value.VectorType)
    
    /// Integrates time into an existing simulation state, returning the resulting
    /// simulation state.
    ///
    /// The integration is done via RK4.
    func integrate(value: Value.VectorType, velocity: Value.VectorType, time: Double) -> (value: Value.VectorType, velocity: Value.VectorType) {
        
        let initial = Derivative(value: .zero, velocity: .zero)
        
        let a = evaluate(value: value, velocity: velocity, time: 0.0, derivative: initial)
        let b = evaluate(value: value, velocity: velocity, time: time * 0.5, derivative: a)
        let c = evaluate(value: value, velocity: velocity, time: time * 0.5, derivative: b)
        let d = evaluate(value: value, velocity: velocity, time: time, derivative: c)
        
        var dxdt = a.value
        dxdt += (2.0 * (b.value + c.value)) + d.value
        dxdt = Double(1.0/6.0) * dxdt
        
        var dvdt = a.velocity
        dvdt += (2.0 * (b.velocity + c.velocity)) + d.velocity
        dvdt = Double(1.0/6.0) * dvdt
        
        return (
            value: value + (time * dxdt),
            velocity: velocity + (time * dvdt)
        )
        
    }
    
    private func evaluate(value: Value.VectorType, velocity: Value.VectorType, time: Double, derivative: Derivative) -> Derivative {
        let nextValue = value + (time * derivative.value)
        let nextVelocity = velocity + (time * derivative.velocity)
        return Derivative(
            value: nextVelocity,
            velocity: acceleration(value: nextValue, velocity: nextVelocity))
    }
    
}
