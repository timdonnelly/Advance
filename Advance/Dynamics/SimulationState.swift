public struct SimulationState<T> where T: VectorConvertible {
    
    public var value: T
    
    public var velocity: T
    
    public init(value: T, velocity: T) {
        self.value = value
        self.velocity = velocity
    }
    
}
