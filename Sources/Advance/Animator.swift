import Foundation

/// Manages the application of animations to a value.
///
/// ```
/// let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
///
/// let sizeAnimator = Animator(initialValue: view.bounds.size)
/// sizeAnimator.onChange = { view.bounds.size = $0 }
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
    
    /// Called every time the animator's `value` changes.
    public var onChange: ((Value) -> Void)? = nil {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
        }
    }
    
    private let displayLink = DisplayLink()
    
    private var state: State {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            displayLink.isPaused = state.isAtRest
            if state.value.animatableData != oldValue.value.animatableData {
                onChange?(state.value)
            }
        }
    }
    
    /// Initializes a new animator with the given value.
    public init(initialValue: Value) {
        dispatchPrecondition(condition: .onQueue(.main))
        state = .atRest(value: initialValue)
        displayLink.onFrame = { [weak self] (frame) in
            self?.advance(by: frame.duration)
        }
    }
    
    private func advance(by time: Double) {
        dispatchPrecondition(condition: .onQueue(.main))
        state.advance(by: time)
    }
    
    /// assigning to this value will remove any running animation.
    public var value: Value {
        get {
            dispatchPrecondition(condition: .onQueue(.main))
            return state.value
        }
        set {
            dispatchPrecondition(condition: .onQueue(.main))
            state = .atRest(value: newValue)
        }
    }
    
    /// The current velocity of the animator.
    public var velocity: Value {
        dispatchPrecondition(condition: .onQueue(.main))
        return state.velocity
    }
    
    /// Animates the property using the given animation.
    public func animate(to finalValue: Value, duration: Double, timingFunction: TimingFunction = .swiftOut) {
        dispatchPrecondition(condition: .onQueue(.main))
        state.animate(to: finalValue, duration: duration, timingFunction: timingFunction)
    }

    /// Animates the property using the given simulation function, imparting the specified initial velocity into the simulation.
    public func simulate<T>(using function: T, initialVelocity: T.Value) where T: SimulationFunction, T.Value == Value {
        dispatchPrecondition(condition: .onQueue(.main))
        state.simulate(using: function, initialVelocity: initialVelocity)
    }
    
    /// Animates the property using the given simulation function.
    public func simulate<T>(using function: T) where T: SimulationFunction, T.Value == Value {
        dispatchPrecondition(condition: .onQueue(.main))
        state.simulate(using: function)
    }

    /// Removes any active animation, freezing the animator at the current value.
    public func cancelRunningAnimation() {
        dispatchPrecondition(condition: .onQueue(.main))
        state = .atRest(value: state.value)
    }

}


extension Animator {
    
    fileprivate enum State {
        case atRest(value: Value)
        case animating(animation: Animation<Value>)
        case simulating(simulation: Simulation<Value>)
        
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
            case .simulating(var simulation):
                simulation.advance(by: time)
                if simulation.hasConverged {
                    self = .atRest(value: simulation.value)
                } else {
                    self = .simulating(simulation: simulation)
                }
            }
        }
        
        var isAtRest: Bool {
            switch self {
            case .atRest: return true
            case .animating: return false
            case .simulating: return false
            }
        }
        
        var value: Value {
            switch self {
            case .atRest(let value): return value
            case .animating(let animation): return animation.value
            case .simulating(let simulation): return simulation.value
            }
        }
        
        var velocity: Value {
            switch self {
            case .atRest(let value):
                var result = value
                result.animatableData = .zero
                return result
            case .animating(let animation): return animation.velocity
            case .simulating(let simulation): return simulation.velocity
            }
        }
        
        mutating func animate(to finalValue: Value, duration: Double, timingFunction: TimingFunction) {
            let animation = Animation(
                from: self.value,
                to: finalValue,
                duration: duration,
                timingFunction: timingFunction)
            self = .animating(animation: animation)
        }
        
        mutating func simulate<T>(using function: T, initialVelocity: Value) where T: SimulationFunction, T.Value == Value {
            let simulation = Simulation(
                function: function,
                initialValue: self.value,
                initialVelocity: initialVelocity)
            
            self = .simulating(simulation: simulation)
        }
        
        mutating func simulate<T>(using function: T) where T: SimulationFunction, T.Value == Value {
            switch self {
            case .atRest, .animating:
                self.simulate(using: function, initialVelocity: self.velocity)
            case .simulating(var simulation):
                simulation.use(function: function)
                self = .simulating(simulation: simulation)
            }
        }
    }
    
}
