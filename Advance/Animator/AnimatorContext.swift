/// Creates and manages `Animator` instances, retaining them until completion.
public final class AnimatorContext {
    
    /// The default context.
    public static let shared = AnimatorContext()
    
    fileprivate var animators: Set<AnimatorWrapper> = []
    
    /// Creates a new animator context.
    public init() {}
    
    deinit {
        for a in animators {
            a.animator.cancel()
        }
    }
    
    /// Generates a new animator instance to run the given animation.
    ///
    /// - parameter animation: The animation to run.
    /// - returns: The newly generated `Animator` instance.
    public func animate<A: Animation>(_ animation: A) -> Animator<A> {
        let a = Animator(animation: animation)
        a.start()
        if a.state == .running {
            let wrapper = AnimatorWrapper(animator: a)
            animators.insert(wrapper)
            let obs: (A)->Void = { [weak self] (a) -> Void in
                _ = self?.animators.remove(wrapper)
            }
            a.cancelled.observe(obs)
            a.finished.observe(obs)
        }
        return a
    }
}

private protocol Cancelable: class {
    func cancel()
}

extension Animator: Cancelable {}

private struct AnimatorWrapper: Hashable {
    let animator: Cancelable
    init<A>(animator: Animator<A>) {
        self.animator = animator
    }
    
    var hashValue: Int {
      return ObjectIdentifier(animator).hashValue
    }
    
    static func ==(lhs: AnimatorWrapper, rhs: AnimatorWrapper) -> Bool {
        return lhs.animator === rhs.animator
    }
    
}


