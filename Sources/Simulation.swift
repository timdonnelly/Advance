import Foundation


/// `Simulator` simulates changes to a value over time, based on
/// a function that calculates acceleration after each time step.
///
/// [The RK4 method](https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods) 
/// is used to integrate the acceleration function.
///
/// Constant time steps are not guaranteed elsewhere in the framework. Due to
/// the nature of dynamic functions, however, it is desirable to maintain
/// a constant update interval for a dynamic simulation. `Simulation`
/// instances maintain their own internal time state. When `advance(elapsed:)
/// is called on an instance, it may run an arbitrary number of time steps
/// internally (and call the underlying function as needed) in order to "catch
/// up" to the outside time. It then uses linear interpolation to match the
/// internal state to the required external time in order to return the most
/// precise calculations.
public struct Simulation<F: SimulationFunction>: Advanceable {
    
    // The internal time step. 0.008 == 120fps (double the typical screen refresh
    // rate). The math required to solve most functions is easy for modern
    // CPUs, but it's worth experimenting with this value if solver calculations
    // ever become a performance bottleneck.
    fileprivate let tickTime: Double = 0.008
    
    /// The function driving the simulation.
    public var function: F {
        didSet {
            // If the function changes, we need to make sure that its new state 
            // will allow the simulation to converge.
            hasConverged = false
            convergeIfPossible()
        }
    }
    
    // Tracks the delta between external and internal time.
    fileprivate var timeAccumulator: Double = 0.0
    
    /// Returns `true` if the solver has converged and does not currently
    /// need to be advanced on each frame.
    fileprivate (set) public var hasConverged: Bool = false
    
    // The current state of the solver.
    fileprivate var simulationState: SimulationState<F.VectorType>
    
    // The latest interpolated state that we use to return values to the outside
    // world.
    fileprivate var interpolatedState: SimulationState<F.VectorType>
    
    /// Creates a new `DynamicSolver` instance.
    ///
    /// - parameter function: The function that will drive the simulation.
    /// - parameter value: The initial value of the simulation.
    /// - parameter velocity: The initial velocity of the simulation.
    public init(function: F, value: F.VectorType, velocity: F.VectorType = F.VectorType.zero) {
        self.function = function
        simulationState = SimulationState(value: value, velocity: velocity)
        interpolatedState = simulationState
        convergeIfPossible()
    }
    
    fileprivate mutating func convergeIfPossible() {
        guard hasConverged == false else { return }
        
        switch function.convergence(for: simulationState) {
        case .keepRunning:
            break
        case let .converge(value):
            simulationState.value = value
            simulationState.velocity = F.VectorType.zero
            interpolatedState = simulationState
            hasConverged = true
        }

    }
    
    /// Advances the simulation.
    ///
    /// - parameter elapsed: The duration by which to advance the simulation
    ///   in seconds.
    public mutating func advance(by time: Double) {
        guard hasConverged == false else { return }
        
        // Limit to 10 physics ticks per update, should never come close.
        let t = min(time, tickTime * 10.0)
        
        // Add the new time to the accumulator. This can be thought of as the
        // delta between the time of the current physics state, and the time
        // that we need to solve for. When it is positive, we need to advance
        // the simulation to catch up.
        timeAccumulator += t
        
        var previousState = simulationState
        
        // Advance the simulation until the time accumulator is negative –
        // this means that the current state is ahead of the needed time.
        while timeAccumulator > 0.0 {
            if hasConverged {
                break
            }
            previousState = simulationState
            simulationState = function.integrate(state: simulationState, time: tickTime)
            timeAccumulator -= tickTime
        }
        
        assert(timeAccumulator <= 0.0)
        assert(timeAccumulator > -tickTime)
        
        // If convergence is possible, we can just do that and avoid interpolation.
        convergeIfPossible()
        
        if hasConverged == false {
            // The simulation did not converge. At this point, the latest state
            // was calculated for some time in the future of what we need
            // to satisfy `elapsed`. We can figure out the alpha in between
            // `previousState` and `simulationState`, and interpolate. This
            // will let us provide a more accurate value to the outside world,
            // while maintaining a consistent time step internally.
            let alpha = Scalar((tickTime + timeAccumulator) / tickTime)
            interpolatedState = previousState
            interpolatedState.value = interpolatedState.value.interpolated(to: simulationState.value, alpha: alpha)
            interpolatedState.velocity = interpolatedState.velocity.interpolated(to: simulationState.velocity, alpha: alpha)
        }
    }
    
    /// The current value.
    public var value: F.VectorType {
        get { return interpolatedState.value }
        set {
            interpolatedState.value = newValue
            simulationState.value = newValue
            hasConverged = false
            convergeIfPossible()
        }
    }
    
    /// The current velocity.
    public var velocity: F.VectorType {
        get { return interpolatedState.velocity }
        set {
            interpolatedState.velocity = newValue
            simulationState.velocity = newValue
            hasConverged = false
            convergeIfPossible()
        }
    }
}
