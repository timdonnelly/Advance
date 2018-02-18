/// Provides type erasure for an animation conforming to ValueAnimation
///
/// - parameter Value: The type of value to be animated.
public struct AnyAnimation<Value: VectorConvertible>: Animation {
    
    /// The current value of the animation.
    public let value: Value
    
    /// The current value of the animation.
    public let velocity: Value
    
    /// `true` if the animation has finished.
    public let isFinished: Bool
    
    // Captures the underlying animation and allows us to advance it.
    fileprivate let advanceFunction: (Double) -> AnyAnimation<Value>
    
    /// Creates a new type-erased animation.
    ///
    /// - parameter animation: The animation to be type erased.
    public init<A: Animation>(animation: A) where A.Value == Value {
        value = animation.value
        velocity = animation.velocity
        isFinished = animation.isFinished
        advanceFunction = { (time: Double) -> AnyAnimation<Value> in
            var a = animation
            a.advance(by: time)
            return AnyAnimation(animation: a)
        }
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(by time: Double) {
        self = advanceFunction(time)
    }
}
