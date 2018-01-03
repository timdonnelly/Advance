/// Provides type erasure for an animation conforming to ValueAnimation
///
/// - parameter Value: The type of value to be animated.
public struct AnyValueAnimation<Value: VectorConvertible>: ValueAnimation {
    
    /// The current value of the animation.
    public let value: Value
    
    /// The current value of the animation.
    public let velocity: Value
    
    /// `true` if the animation has finished.
    public let finished: Bool
    
    // Captures the underlying animation and allows us to advance it.
    fileprivate let advanceFunction: (Double) -> AnyValueAnimation<Value>
    
    /// Creates a new type-erased animation.
    ///
    /// - parameter animation: The animation to be type erased.
    public init<A: ValueAnimation>(animation: A) where A.Value == Value {
        value = animation.value
        velocity = animation.velocity
        finished = animation.finished
        advanceFunction = { (time: Double) -> AnyValueAnimation<Value> in
            var a = animation
            a.advance(by: time)
            return AnyValueAnimation(animation: a)
        }
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(by time: Double) {
        self = advanceFunction(time)
    }
}
