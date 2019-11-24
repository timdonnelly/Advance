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
            if state.value != oldValue.value {
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
        let completion = state.completion
        state.advance(by: time)
        if state.isAtRest {
            completion?(.finished)
        }
    }
    
    /// assigning to this value will remove any running animation.
    public var value: Value {
        get {
            dispatchPrecondition(condition: .onQueue(.main))
            return state.value
        }
        set {
            dispatchPrecondition(condition: .onQueue(.main))
            enter(state: .atRest(value: newValue))
        }
    }
    
    /// The current velocity of the animator.
    public var velocity: Value {
        dispatchPrecondition(condition: .onQueue(.main))
        return state.velocity
    }
    
    /// Animates the property using the given animation.
    public func animate(to finalValue: Value, duration: Double, timingFunction: TimingFunction = .swiftOut, completion: @escaping (CompletionReason) -> Void = { _ in }) {
        dispatchPrecondition(condition: .onQueue(.main))
        var newState = state
        newState.animate(to: finalValue, duration: duration, timingFunction: timingFunction, completion: completion)
        enter(state: newState)
    }

    /// Animates the property using the given simulation function, imparting the specified initial velocity into the simulation.
    public func simulate<T>(using function: T, initialVelocity: T.Value, completion: @escaping (CompletionReason) -> Void = { _ in }) where T: SimulationFunction, T.Value == Value {
        dispatchPrecondition(condition: .onQueue(.main))
        var newState = state
        newState.simulate(using: function, initialVelocity: initialVelocity, completion: completion)
        enter(state: newState)
    }
    
    /// Animates the property using the given simulation function.
    public func simulate<T>(using function: T, completion: @escaping (CompletionReason) -> Void = { _ in }) where T: SimulationFunction, T.Value == Value {
        dispatchPrecondition(condition: .onQueue(.main))
        var newState = state
        newState.simulate(using: function, completion: completion)
        enter(state: newState)
    }

    /// Removes any active animation, freezing the animator at the current value.
    public func cancelRunningAnimation() {
        dispatchPrecondition(condition: .onQueue(.main))
        enter(state: .atRest(value: state.value))
    }
    
    private func enter(state: State) {
        let previousCompletion = self.state.completion
        self.state = state
        previousCompletion?(.interrupted)
    }

}

extension Animator {
    
    /// Represents the reason that an animation or simulation completed.
    public enum CompletionReason: Equatable {
        
        /// The animation or simulation finished successfully
        case finished
        
        /// The animation or simulation was interrupted before it could finish
        case interrupted
    }
    
}

extension Animator {
    
    fileprivate enum State {
        case atRest(value: Value)
        case animating(animation: Animation<Value>, completion: (CompletionReason) -> Void)
        case simulating(simulation: Simulation<Value>, completion: (CompletionReason) -> Void)
        
        mutating func advance(by time: Double) {
            switch self {
            case .atRest: break
            case .animating(var animation, let completion):
                animation.advance(by: time)
                if animation.isFinished {
                    self = .atRest(value: animation.value)
                } else {
                    self = .animating(animation: animation, completion: completion)
                }
            case .simulating(var simulation, let completion):
                simulation.advance(by: time)
                if simulation.hasConverged {
                    self = .atRest(value: simulation.value)
                } else {
                    self = .simulating(simulation: simulation, completion: completion)
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
            case .animating(let animation, _): return animation.value
            case .simulating(let simulation, _): return simulation.value
            }
        }
        
        var velocity: Value {
            switch self {
            case .atRest(_): return .zero
            case .animating(let animation, _): return animation.velocity
            case .simulating(let simulation, _): return simulation.velocity
            }
        }
        
        var completion: ((CompletionReason) -> Void)? {
            switch self {
            case .atRest(_): return nil
            case .animating(_, let completion): return completion
            case .simulating(_, let completion): return completion
            }
        }
        
        mutating func animate(to finalValue: Value, duration: Double, timingFunction: TimingFunction, completion: @escaping (CompletionReason) -> Void) {
            let animation = Animation(
                from: self.value,
                to: finalValue,
                duration: duration,
                timingFunction: timingFunction)
            
            self = .animating(animation: animation, completion: completion)
        }
        
        mutating func simulate<T>(using function: T, initialVelocity: Value, completion: @escaping (CompletionReason) -> Void) where T: SimulationFunction, T.Value == Value {
            let simulation = Simulation(
                function: function,
                initialValue: self.value,
                initialVelocity: initialVelocity)
            
            self = .simulating(simulation: simulation, completion: completion)
        }
        
        mutating func simulate<T>(using function: T, completion: @escaping (CompletionReason) -> Void) where T: SimulationFunction, T.Value == Value {
            switch self {
            case .atRest, .animating:
                self.simulate(using: function, initialVelocity: self.velocity, completion: completion)
            case .simulating(var simulation, _):
                simulation.use(function: function)
                self = .simulating(simulation: simulation, completion: completion)
            }
        }

    }
    
}
