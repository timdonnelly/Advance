public struct AnyAnimation<Element>: Animation {
    
    public let value: Element
    
    public let isFinished: Bool
    
    private let _advance: (Double) -> AnyAnimation<Element>
    
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
