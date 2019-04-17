/// Interpolates between values over a specified duration.
///
/// - parameter Value: The type of value to be animated.
struct Animation<Value: VectorConvertible> {
    
    /// The initial value at time 0.
    let from: Value
    
    /// The final value when the animation is finished.
    let to: Value
    
    /// The duration of the animation in seconds.
    let duration: Double
    
    /// The timing function that is used to map elapsed time to an
    /// interpolated value.
    let timingFunction: TimingFunction
    
    /// The current value.
    private (set) var value: Value
    
    private (set) var velocity: Value
    
    private var elapsed: Double = 0.0
    
    /// Creates a new `BasicAnimation` instance.
    ///
    /// - parameter from: The value at time `0`.
    /// - parameter to: The value at the end of the animation.
    /// - parameter duration: How long (in seconds) the animation should last.
    /// - parameter timingFunction: The timing function to use.
    init(from: Value, to: Value, duration: Double, timingFunction: TimingFunction = UnitBezier.swiftOut) {
        self.from = from
        self.to = to
        self.duration = duration
        self.timingFunction = timingFunction
        self.value = from
        self.velocity = .zero
    }
    

    /// Returns `true` if the advanced time is `>=` duration.
    var isFinished: Bool {
        return elapsed >= duration
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    mutating func advance(by time: Double) {
        
        let starting = value
        
        elapsed += time
        var progress = elapsed / duration
        progress = max(progress, 0.0)
        progress = min(progress, 1.0)
        let adjustedProgress = timingFunction.solve(at: progress, epsilon: 1.0 / (duration * 1000.0))
        
        value = Value(vector: interpolate(from: from.vector, to: to.vector, alpha: adjustedProgress))
        
        let vel = (1.0/time) * (value.vector - starting.vector)
        velocity = Value(vector: vel)
    }
    
}
