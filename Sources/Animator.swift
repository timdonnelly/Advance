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
    
    private let loop = Loop()
    
    private var state: State {
        didSet {
            loop.paused = state.isAtRest
            valueSink.send(value: state.value)
        }
    }
    
    public init(value: Value) {
        state = .atRest(value: value)
        
        loop.observe { [weak self] (frame) in
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


