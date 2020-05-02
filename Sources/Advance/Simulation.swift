import SwiftUI
import Combine

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
public final class Simulation<Function: SimulationFunction>: ObservableObject {
    
    @Published private var state: SimulationState<Function> {
        didSet {
            updateDisplayLink()
        }
    }
    
    private let displayLink = DisplayLink()
    
    /// Initializes a new animator with the given value.
    public init(function: Function, initialValue: Function.Value) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        var velocity = initialValue
        velocity.animatableData = .zero
        
        state = SimulationState(function: function, initialValue: initialValue, initialVelocity: velocity)
    }
    
    private func advance(by time: Double) {
        dispatchPrecondition(condition: .onQueue(.main))
        state.advance(by: time)
    }
    
    private func updateDisplayLink() {
        displayLink.isPaused = state.hasConverged
    }
    
    public var function: Function {
        get {
            dispatchPrecondition(condition: .onQueue(.main))
            return state.function
        }
        set {
            dispatchPrecondition(condition: .onQueue(.main))
            state.function = newValue
        }
    }
    
    /// assigning to this value will remove any running animation.
    public var value: Function.Value {
        get {
            dispatchPrecondition(condition: .onQueue(.main))
            return state.value
        }
        set {
            dispatchPrecondition(condition: .onQueue(.main))
            state.value = newValue
        }
    }
    
    /// The current velocity of the animator.
    public var velocity: Function.Value {
        get {
            dispatchPrecondition(condition: .onQueue(.main))
            return state.velocity
        }
        set {
            dispatchPrecondition(condition: .onQueue(.main))
            state.velocity = newValue
        }
    }
    
}
