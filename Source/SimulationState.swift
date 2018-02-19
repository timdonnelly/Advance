/// The current state of a running simulation.
public struct SimulationState<T> where T: Vector {
    
    /// The current value of a running simulation.
    public var value: T
    
    /// The current velocity of a running simulation.
    public var velocity: T
    
    /// Initializes a new simulation state.
    public init(value: T, velocity: T) {
        self.value = value
        self.velocity = velocity
    }
    
}
