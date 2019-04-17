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
public final class Animator<Value: VectorConvertible> {
    
    public var onChange: ((Value) -> Void)? = nil
    
    private let displayLink = DisplayLink()
    
    private var state: State {
        didSet {
            displayLink.isPaused = state.isAtRest
            if state.value != oldValue.value {
                onChange?(state.value)
            }
        }
    }
    
    public init(initialValue: Value) {
        state = .atRest(value: initialValue)
        
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
    public func animate(to finalValue: Value, duration: Double, timingFunction: TimingFunction = UnitBezier.swiftOut) {
        let animation = Animation(from: value, to: finalValue, duration: duration, timingFunction: timingFunction)
        state = .animating(animation: animation)
    }

    /// Animates the property using the given animation.
    public func simulate<T>(with function: T, initialValue: T.Value, initialVelocity: T.Value) where T: SimulationFunction, T.Value == Value {

        let simulation = Simulation(
            function: function,
            initialValue: initialValue,
            initialVelocity: initialVelocity)

        state = .simulating(simulation: simulation)
    }
    
    /// Animates the property using the given animation.
    public func simulate<T>(with function: T) where T: SimulationFunction, T.Value == Value {
        self.simulate(with: function, initialValue: self.value, initialVelocity: self.velocity)
    }

    public func cancelRunningAnimation() {
        state = .atRest(value: state.value)
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
        var function = SpringFunction(target: target)
        function.tension = tension
        function.damping = damping
        function.threshold = threshold

        simulate(with: function, initialValue: self.value, initialVelocity: initialVelocity)
    }

}

extension Animator {

    /// Starts a decay animation with the current velocity of the property animator.
    public func decay(drag: Double = 3.0, threshold: Double = 0.1) {
        decay(initialVelocity: velocity, drag: drag, threshold: threshold)
    }

    /// Starts a decay animation with the given initial velocity.
    public func decay(initialVelocity: Value, drag: Double = 3.0, threshold: Double = 0.1) {
        let function = DecayFunction<Value>(threshold: threshold, drag: drag)
        simulate(with: function, initialValue: value, initialVelocity: initialVelocity)
    }
}

