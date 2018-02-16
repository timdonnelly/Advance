public struct DynamicsState<T> where T: Vector {
    
    var value: T
    
    var velocity: T
    
    init(value: T, velocity: T) {
        self.value = value
        self.velocity = velocity
    }
    
}
