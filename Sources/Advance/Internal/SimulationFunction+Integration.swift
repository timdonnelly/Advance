// The internal time step. 0.008 == 120fps (double the typical screen refresh
// rate). The math required to solve most functions is easy for modern
// CPUs, but it's worth experimenting with this value if solver calculations
// ever become a performance bottleneck.
let simulationFrameDuration: Double = 0.008


/// [The RK4 method](https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods)
/// is used to integrate the acceleration function.
extension SimulationFunction {
    
    private typealias Derivative = (value: Value.AnimatableData, velocity: Value.AnimatableData)
    
    /// Integrates time into an existing simulation state, returning the resulting
    /// simulation state.
    ///
    /// The integration is done via RK4.
    func integrate(value: Value, velocity: Value, time: Double) -> (value: Value, velocity: Value) {
        
        let initial = Derivative(value: .zero, velocity: .zero)
        
        let a = evaluate(value: value.animatableData, velocity: velocity.animatableData, time: 0.0, derivative: initial)
        let b = evaluate(value: value.animatableData, velocity: velocity.animatableData, time: time * 0.5, derivative: a)
        let c = evaluate(value: value.animatableData, velocity: velocity.animatableData, time: time * 0.5, derivative: b)
        let d = evaluate(value: value.animatableData, velocity: velocity.animatableData, time: time, derivative: c)
        
        var dxdt = b.value + c.value
        dxdt.scale(by: 2.0)
        dxdt += d.value
        dxdt.scale(by: 1.0/6.0)
        
        var dvdt = b.velocity + c.velocity
        dvdt.scale(by: 2.0)
        dvdt += d.velocity
        dvdt.scale(by: 1.0/6.0)
        
        dxdt.scale(by: time)
        dvdt.scale(by: time)
        
        var resultValue = value
        resultValue.animatableData += dxdt
        
        var resultVelocity = velocity
        resultVelocity.animatableData += dvdt
        
        return (
            value: resultValue,
            velocity: resultVelocity
        )
        
    }
    
    private func evaluate(value: Value.AnimatableData, velocity: Value.AnimatableData, time: Double, derivative: Derivative) -> Derivative {
        var nextValue = derivative.value
        nextValue.scale(by: time)
        nextValue += value
        
        var nextVelocity = derivative.velocity
        nextVelocity.scale(by: time)
        nextVelocity += velocity
        
        return Derivative(
            value: nextVelocity,
            velocity: acceleration(value: nextValue, velocity: nextVelocity))
    }
    
}

extension SpringFunction {
    
    /// Estimates the value that the simulation will ultimately converge at, and the time that is required to reach convergence.
    ///
    /// - Parameter initialValue: The initial value of the simulation
    /// - Parameter initialVelocity: The initial velocity of the simulation
    /// - Parameter maximumDuration: The maximum simulation time to calculate. Some simulation functions may never converge, so we need
    ///   a way to cap the search.
    ///
    /// - Returns: The converged value and the time required to reach convergence (if successful), or nil if convergence was not reached
    ///   within the given `maximumDuration`.
    func estimatedConvergence(initialValue: Value, initialVelocity: Value, maximumDuration: Double) -> (value: Value, duration: Double)? {
        
        var value = initialValue
        var velocity = initialVelocity
        var duration: Double = 0.0
        var hasConverged: Bool = false
        
        while !hasConverged {
            (value, velocity) = integrate(value: value, velocity: velocity, time: simulationFrameDuration)
            duration += simulationFrameDuration
            switch convergence(value: value.animatableData, velocity: velocity.animatableData) {
            case .keepRunning:
                continue
            case .converge(atValue: let convergedValue):
                value.animatableData = convergedValue
                hasConverged = true
            }
            
            if duration > maximumDuration {
                return nil
            }
        }
        
        return (value: value, duration: duration)
    }
    
}
