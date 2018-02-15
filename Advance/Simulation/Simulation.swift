public protocol Simulation: Advanceable {
    
    /// Returns true if the simulation is in a settled state.
    var isSettled: Bool { get }
    
}
