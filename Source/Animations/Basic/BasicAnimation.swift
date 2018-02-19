/// Interpolates between values over a specified duration.
///
/// - parameter Value: The type of value to be animated.
public struct BasicAnimation<Value>: Animation where Value: Interpolatable {
    
    /// The initial value at time 0.
    fileprivate (set) public var from: Value
    
    /// The final value when the animation is finished.
    fileprivate (set) public var to: Value
    
    /// The duration of the animation in seconds.
    fileprivate (set) public var duration: Double
    
    /// The timing function that is used to map elapsed time to an
    /// interpolated value.
    fileprivate (set) public var timingFunction: TimingFunction
    
    /// Creates a new `BasicAnimation` instance.
    ///
    /// - parameter from: The value at time `0`.
    /// - parameter to: The value at the end of the animation.
    /// - parameter duration: How long (in seconds) the animation should last.
    /// - parameter timingFunction: The timing function to use.
    public init(from: Value, to: Value, duration: Double, timingFunction: TimingFunction = UnitBezier.swiftOut) {
        self.from = from
        self.to = to
        self.duration = duration
        self.timingFunction = timingFunction
        self.value = from
    }
    
    /// The current value.
    fileprivate(set) public var value: Value
    
    fileprivate var elapsed: Double = 0.0
    
    /// Returns `true` if the advanced time is `>=` duration.
    public var isFinished: Bool {
        return elapsed >= duration
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(by time: Double) {
        
        elapsed += time
        var progress = elapsed / duration
        progress = max(progress, 0.0)
        progress = min(progress, 1.0)
        let adjustedProgress = timingFunction.solve(at: Scalar(progress), epsilon: 1.0 / Scalar(duration * 1000.0))
        
        value = from.interpolated(to: to, alpha: Scalar(adjustedProgress))
    }
    
}

public extension PropertyAnimator where Value: Interpolatable {
    
    @discardableResult
    public func animate(to finalValue: Value, duration: Double, timingFunction: TimingFunction = UnitBezier.swiftOut) -> Animator<Value> {
        let animation = BasicAnimation(from: currentValue, to: finalValue, duration: duration, timingFunction: timingFunction)
        return animate(with: animation)
    }
    
}

public extension Interpolatable {
    
    public func animation(to finalValue: Self, duration: Double, timingFunction: TimingFunction = UnitBezier.swiftOut) -> BasicAnimation<Self> {
        return BasicAnimation(from: self, to: finalValue, duration: duration, timingFunction: timingFunction)
    }
    
}
