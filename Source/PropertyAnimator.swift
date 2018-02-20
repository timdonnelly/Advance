/// Manages the application of animations to a property of type `Value` on
/// the target object.
///
/// Property animators retain the target object, so they should *not* be used
/// to animate properties of `self`.
///
/// ```
/// let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
///
/// let sizeAnimator = PropertyAnimator(target: view, keyPath: \.bounds.size)
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
public final class PropertyAnimator<Target, Value> where Target: AnyObject, Value: VectorConvertible {
    
    /// The object to be animated.
    public let target: Target
    
    /// The keypath describing the property to be animated.
    public let keyPath: ReferenceWritableKeyPath<Target, Value>
    
    private var currentAnimationRunner: AnimationRunner<Value>? = nil
    
    /// Initializes a new property animator with the given target and keypath.
    public init(target: Target, keyPath: ReferenceWritableKeyPath<Target, Value>) {
        self.target = target
        self.keyPath = keyPath
    }
    
    /// Animates the property using the given animation.
    @discardableResult
    public func animate<T>(with animation: T) -> AnimationRunner<Value> where T: Animation, T.Value == Value {
        
        cancelRunningAnimation()
        let runner = AnimationRunner(animation: animation)
            
        runner.bind(to: target, keyPath: keyPath)
        runner.onCompletion({ [weak self] (_) in
            self?.runnerDidFinish(runner)
        })

        self.currentAnimationRunner = runner
        
        runner.start()
        
        return runner
    }
    
    private func runnerDidFinish(_ runner: AnimationRunner<Value>) {
        if runner === currentAnimationRunner {
            currentAnimationRunner = nil
        }
    }
    
    /// Returns true if an animation is in progress.
    public var isAnimating: Bool {
        return currentAnimationRunner != nil
    }
    
    /// Cancels any running animation.
    public func cancelRunningAnimation() {
        currentAnimationRunner?.cancel()
        currentAnimationRunner = nil
    }
    
    /// assigning to this value will remove any running animation.
    public var value: Value {
        get {
            return target[keyPath: keyPath]
        }
        set {
            cancelRunningAnimation()
            target[keyPath: keyPath] = newValue
        }
    }
    
    public var velocity: Value {
        return currentAnimationRunner?.velocity ?? .zero
    }
}

