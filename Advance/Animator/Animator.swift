public extension Animator {
    
    /// The state of an `Animator` instance.
    public enum State: Equatable {
        /// The animator has not yet started.
        case pending
        
        /// The animator is currently running.
        case running
        
        /// The animator has stopped running.
        case completed(Result)
        
        /// Equatable
        public static func ==(lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.pending, .pending):
                return true
            case (.running, .running):
                return true
            case (.completed(let l), .completed(let r)):
                return l == r
            default:
                return false
            }
        }
        
    }
    
}

public extension Animator.State {
    
    /// The possible result cases of an animator.
    public enum Result {
        /// The animator was cancelled before the animation completed.
        case cancelled
        
        /// The animator successfully ran the animation until it was finished.
        case finished
    }
    
}



/// Runs an animation until the animations finishes, or until `cancel()` 
/// is called.
///
/// The `Animator` class is one-shot: It runs the animation precisely one time.
///
/// It starts in the `Pending` state. From here either:
/// - It enters the running state. This occurs if start() is called.
/// - It is cancelled. This occurs if cancel() is called, and causes the animator
///   to enter the `Completed` state, with a result of `Cancelled`.
///
/// After entering the `Running` state, the `started` event is fired. The 
/// animation then updates on every frame, triggering the `changed` event each
/// time, until either:
/// - The animation finishes on its own, after which the animator enters the
///   `Completed` state, with a result of `Finished`.
/// - `cancel()` is called, after which the animator enters the `Completed`
///   state, with a result of `Cancelled`.
///
/// When the animator enters the `Completed` state, it triggers either the
/// `cancelled` or `finished` event, depending on the result. After entering
/// the `Completed` state, the animator is finished and no further state changes
/// can occur.
public final class Animator<A: Animation> {
    
    fileprivate lazy var subscription: Loop.Subscription? = {
        
        let s = Loop.shared.subscribe()
        
        s.advanced.observe({ [unowned self] (elapsed) -> Void in
            guard self.state == .running else { return }
            self.animation.advance(by: elapsed)
            self.changedSink.send(value: self.animation)
            if self.animation.finished == true {
                self.finish()
            }
        })
        
        return s
    }()
    
    /// The current state of the animator. Animators begin in a running state,
    /// and they are guarenteed to transition into either the cancelled or
    /// finished state exactly one time – no further state changes are allowed.
    fileprivate (set) public var state: State = .pending {
        willSet {
            guard newValue != state else { return }
            switch newValue {
            case .pending:
                assert(false, "Invalid state transition")
            case .running:
                assert(state == .pending, "Invalid state transition")
            case .completed(_):
                assert(state == .pending || state == .running, "Invalid state transition")
            }
        }
        didSet {
            guard oldValue != state else { return }
            switch state {
            case .pending:
                break
            case .running:
                break
            case .completed(let result):
                switch result {
                case .cancelled:
                    cancelledSink.send(value: animation)
                case .finished:
                    finishedSink.send(value: animation)
                }
            }
        }
    }
    
    /// The animation that is being run.
    fileprivate (set) public var animation: A
    
    private let changedSink = Sink<A>()
    private let cancelledSink = Sink<A>()
    private let finishedSink = Sink<A>()
    
    /// Fired after every animation update.
    public var changed: Observable<A> {
        return changedSink.observable
    }
    
    /// Fired if the animator is cancelled.
    public var cancelled: Observable<A> {
        return cancelledSink.observable
    }
    
    /// Fired when the animation finishes.
    public var finished: Observable<A> {
        return finishedSink.observable
    }
    
    /// Creates a new animator.
    ///
    /// - parameter animation: The animation to be run.
    public init(animation: A, loop: Loop = Loop.shared) {
        self.animation = animation
    }
    
    deinit {
        if state == .running || state == .pending {
            cancel()
        }
    }
    
    
    /// Starts a pending animation
    ///
    /// If the animator is not in a `pending` state, calling start() will have
    /// no effect.
    public func start() {
        guard state == .pending else { return }
        state = .running
        if animation.finished == true {
            finish()
        } else {
            subscription?.paused = false
        }
    }
    
    /// Cancels the animation.
    ///
    /// If the animator is in a `running` or `pending` state, this will immediately
    /// transition to the `cancelled` state (and call any `onCancel` observers). 
    /// If the animator is already cancelled or finished, calling `cancel()` will 
    /// have no effect.
    public func cancel() {
        guard state == .running || state == .pending else { return }
        state = .completed(.cancelled)
        subscription = nil
    }
    
    fileprivate func finish() {
        assert(state == .running || state == .pending)
        state = .completed(.finished)
        subscription = nil
    }
}
