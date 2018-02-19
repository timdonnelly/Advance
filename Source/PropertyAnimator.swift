/// Manages the application of animationss to a property of type `Value` on
/// the target object.
///
/// Property animators retain the target object, so they should *not* be used
/// to animate properties of `self`.
public final class PropertyAnimator<Target, Value> where Target: AnyObject, Value: VectorConvertible {
    
    /// The object to be animated.
    public let target: Target
    
    /// The keypath describing the property to be animated.
    public let keyPath: ReferenceWritableKeyPath<Target, Value>
    
    private var runningAnimator: Animator<Value>? = nil
    
    /// Initializes a new property animator with the given target and keypath.
    public init(target: Target, keyPath: ReferenceWritableKeyPath<Target, Value>) {
        self.target = target
        self.keyPath = keyPath
    }
    
    /// Animates the property using the given animation.
    @discardableResult
    public func animate<T>(with animation: T) -> Animator<Value> where T: Animation, T.Value == Value {
        
        cancelRunningAnimation()
        let animator = animation.run()
            
        animator.bind(to: target, keyPath: keyPath)
        animator.onCompletion({ [weak self] (_) in
            self?.animatorDidFinish(animator)
        })

        self.runningAnimator = animator
        
        return animator
    }
    
    private func animatorDidFinish(_ animator: Animator<Value>) {
        if animator === runningAnimator {
            runningAnimator = nil
        }
    }
    
    /// Returns true if an animation is in progress.
    public var isAnimating: Bool {
        return runningAnimator != nil
    }
    
    /// Cancels any running animation.
    public func cancelRunningAnimation() {
        runningAnimator?.cancel()
        runningAnimator = nil
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
        return runningAnimator?.velocity ?? .zero
    }
}

