/// Manages the application of animations to a value.
///
/// ```
/// let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
///
/// let sizeAnimator = Animator(boundTo: view, keyPath: \.bounds.size)
///
/// /// Spring physics will move the view's size to the new value.
/// sizeAnimator.spring(to: CGSize(width: 300, height: 300))
///
/// /// Some time in the future...
///
/// /// The value will keep the same velocity that it had from the preceeding
/// /// animation, and a decay function will slowly bring movement to a stop.
/// sizeAnimator.decay(drag: 2.0)
/// ```
///
public final class Animator<Value> where Value: VectorConvertible {
    
    fileprivate let valueSink = Sink<Value>()
    
    private let displayLink = DisplayLink()
    
    private var state: State {
        didSet {
            displayLink.isPaused = state.isAtRest
            valueSink.send(value: state.value)
        }
    }
    
    public init(value: Value) {
        state = .atRest(value: value)
        
        displayLink.onFrame = { [weak self] (frame) in
            self?.advance(by: frame.duration)
        }
    }
    
    private func advance(by time: Double) {
        state.advance(by: time)
    }
    
    /// assigning to this value will remove any running animation.
    public var value: Value {
        get {
            return state.value
        }
        set {
            state = .atRest(value: newValue)
        }
    }
    
    public var velocity: Value {
        return state.velocity
    }
    
    /// Animates the property using the given animation.
    public func animate<T>(with animation: T) where T: Animation, T.Value == Value {
        state = .animating(animation: AnyAnimation(animation))
    }
    
    public func cancelRunningAnimation() {
        state = .atRest(value: state.value)
    }

}

extension Animator {
    
    public func simulate<T>(function: T, initialValue: Value, initialVelocity: Value) where T: SimulationFunction, T.VectorType == Value.VectorType {
        let animation = SimulationAnimation(
            function: function,
            value: initialValue,
            velocity: initialVelocity)
        animate(with: animation)
    }
    
    public func simulate<T>(function: T) where T: SimulationFunction, T.VectorType == Value.VectorType {
        let animation = SimulationAnimation(
            function: function, value:
            self.value, velocity:
            self.velocity)
        animate(with: animation)
    }
    
}

extension Animator {
    
    /// Starts a spring animation with the given properties, adopting the property's
    /// current velocity as `initialVelocity`.
    public func spring(to target: Value, tension: Double = 30.0, damping: Double = 5.0, threshold: Double = 0.1) {
        self.spring(to: target, initialVelocity: velocity, tension: tension, damping: damping, threshold: threshold)
    }
    
    /// Starts a spring animation with the given properties.
    public func spring(to target: Value, initialVelocity: Value, tension: Double = 30.0, damping: Double = 5.0, threshold: Double = 0.1) {
        var function = SpringFunction(target: target.vector)
        function.tension = tension
        function.damping = damping
        function.threshold = threshold
        
        simulate(function: function, initialValue: self.value, initialVelocity: initialVelocity)
    }
    
}

extension Animator {
    
    /// Starts a decay animation with the current velocity of the property animator.
    public func decay(drag: Double = 3.0, threshold: Double = 0.1) {
        decay(initialVelocity: velocity, drag: drag, threshold: threshold)
    }
    
    /// Starts a decay animation with the given initial velocity.
    public func decay(initialVelocity: Value, drag: Double = 3.0, threshold: Double = 0.1) {
        var function = DecayFunction<Value.VectorType>()
        function.drag = drag
        function.threshold = threshold
        simulate(function: function, initialValue: value, initialVelocity: initialVelocity)
    }
}

extension Animator {
    
    public func animate(to finalValue: Value, duration: Double, timingFunction: TimingFunction = UnitBezier.swiftOut) {
        let animation = TimedAnimation(from: value, to: finalValue, duration: duration, timingFunction: timingFunction)
        animate(with: animation)
    }
    
}



extension Animator: Observable {
    
    @discardableResult
    public func observe(_ observer: @escaping (Value) -> Void) -> Subscription {
        return valueSink.observe(observer)
    }
    
}

extension Animator {
    
    fileprivate enum State: Advanceable {
        case atRest(value: Value)
        case animating(animation: AnyAnimation<Value>)
        
        
        mutating func advance(by time: Double) {
            switch self {
            case .atRest: break
            case .animating(var animation):
                animation.advance(by: time)
                if animation.isFinished {
                    self = .atRest(value: animation.value)
                } else {
                    self = .animating(animation: animation)
                }
            }
        }
        
        
        var isAtRest: Bool {
            switch self {
            case .atRest: return true
            case .animating: return false
            }
        }
        
        var value: Value {
            switch self {
            case .atRest(let value): return value
            case .animating(let animation): return animation.value
            }
        }
        
        var velocity: Value {
            switch self {
            case .atRest(_): return .zero
            case .animating(let animation): return animation.velocity
            }
        }
        
    }
    
}
