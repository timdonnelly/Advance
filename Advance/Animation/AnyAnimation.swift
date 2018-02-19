/// Provides type erasure for an animation conforming to ValueAnimation
///
/// - parameter Value: The type of value to be animated.
public struct AnyAnimation<Result>: Animation {
    
    /// The current value of the animation.
    public let value: Result
    
    /// `true` if the animation has finished.
    public let isFinished: Bool
    
    // Captures the underlying animation and allows us to advance it.
    fileprivate let advanceFunction: (Double) -> AnyAnimation<Result>
    
    /// Creates a new type-erased animation.
    ///
    /// - parameter animation: The animation to be type erased.
    public init<A: Animation>(animation: A) where A.Result == Result {
        value = animation.value
        isFinished = animation.isFinished
        advanceFunction = { (time: Double) -> AnyAnimation<Result> in
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
