public struct DynamicsState<T> where T: Vector {
    
    public var value: T
    
    public var velocity: T
    
    public init(value: T, velocity: T) {
        self.value = value
        self.velocity = velocity
    }
    
}
