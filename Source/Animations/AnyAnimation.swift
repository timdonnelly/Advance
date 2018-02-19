/// A type-erased wrapper around an animation.
public struct AnyAnimation<Element>: Animation {
    
    /// The current value of the wrapped animation.
    public let value: Element
    
    /// The finished state of the wrapped animation.
    public let isFinished: Bool
    
    private let _advance: (Double) -> AnyAnimation<Element>
    
    /// Initializes a new type-erased wrapper with the given animation.
    public init<T>(_ animation: T) where T: Animation, T.Element == Element {
        value = animation.value
        isFinished = animation.isFinished
        
        _advance = { time in
            var nextAnimation = animation
            nextAnimation.advance(by: time)
            return AnyAnimation(nextAnimation)
        }
        
    }
    
    public mutating func advance(by time: Double) {
        self = _advance(time)
    }
    
}
