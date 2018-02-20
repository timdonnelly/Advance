/// A type-erased wrapper around an animation.
public struct AnyAnimation<Value>: Animation where Value: VectorConvertible {
    
    /// The current value of the wrapped animation.
    public let value: Value
    
    /// The current velocity of the wrapped animation.
    public let velocity: Value
    
    /// The finished state of the wrapped animation.
    public let isFinished: Bool
    
    private let _advance: (Double) -> AnyAnimation<Value>
    
    /// Initializes a new type-erased wrapper with the given animation.
    public init<T>(_ animation: T) where T: Animation, T.Value == Value {
        value = animation.value
        velocity = animation.velocity
        isFinished = animation.isFinished
        
        _advance = { time in
            var nextAnimation = animation
            nextAnimation.advance(by: time)
            return AnyAnimation(nextAnimation)
        }
        
    }
    
    /// Advances the wrapped animation.
    public mutating func advance(by time: Double) {
        self = _advance(time)
    }
    
}
