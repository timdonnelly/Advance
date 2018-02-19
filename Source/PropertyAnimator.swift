/// Manages the application of animaties to a property of an object.
/// Property animators retain the target object, so they should *not* be used
/// to animate properties of `self`.
public final class PropertyAnimator<Target, Value> where Target: AnyObject {
    
    public let target: Target
    
    public let keyPath: ReferenceWritableKeyPath<Target, Value>
    
    private var runningAnimator: Animator<Value>? = nil
    
    public init(target: Target, keyPath: ReferenceWritableKeyPath<Target, Value>) {
        self.target = target
        self.keyPath = keyPath
    }
    
    @discardableResult
    public func animate<T>(with animation: T) -> Animator<Value> where T: Animation, T.Element == Value {
        
        cancelRunningAnimation()
        let animator = animation.run()
            
        animator.bind(to: target, keyPath: keyPath)
        animator.onCompletion({ [weak self] (_) in
            self?.animatorDidFinish(animator)
        })

        self.runningAnimator = animator
        
        return animator
    }
    
    @discardableResult
    public func animate<T>(generator: (Value) -> T) -> Animator<Value> where T: Animation, T.Element == Value {
        let animation = generator(currentValue)
        return animate(with: animation)
    }
    
    private func animatorDidFinish(_ animator: Animator<Value>) {
        if animator === runningAnimator {
            runningAnimator = nil
        }
    }
    
    public var isAnimating: Bool {
        return runningAnimator != nil
    }
    
    public func cancelRunningAnimation() {
        runningAnimator?.cancel()
        runningAnimator = nil
    }
    
    /// assigning to this value will remove any running animation.
    public var currentValue: Value {
        get {
            return target[keyPath: keyPath]
        }
        set {
            cancelRunningAnimation()
            target[keyPath: keyPath] = newValue
        }
    }
}

