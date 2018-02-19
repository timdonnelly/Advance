/// Runs an animation until it is either finished or cancelled.
/// Animators cannot be reused:
/// - They begin in a 'running' state
/// - If the animation finishes, the animator enters the `completed (finished)` state.
/// - If `cancel()` is called on the animator while in a running state, the
///   animator enters the `completed (cancelled)` state.
public final class Animator<T> where T: Animation {

    private (set) public var state: State

    private var animation: T
    private let loop: Loop
    private let valueSink: Sink<T.Result>
    
    private var completionHandlers: [(Result) -> Void]
    private var changeHandlers: [(T.Result) -> Void]
    
    /// Instantiates a new animator for the given animation.
    /// The animator begins running immediately.
    public init(animation: T) {
        self.animation = animation
        self.state = State.running
        self.loop = Loop()
        self.changeHandlers = []
        self.completionHandlers = []
        self.valueSink = Sink()
        
        if animation.isFinished {
            self.state = State.done(result: .finished)
        }
        
        loop.frames.observe { [weak self] (frame) in
            self?.advance(by: frame.duration)
        }
        
        onCompletion { (_) in
            /// Intentionally retain self. All completion handlers are dicarded at the
            /// completion of an animation, so the animator will automatically be
            /// cleaned up when the animation cancels or finishes.
            self.breakIntentionalRetainCycle()
        }
        
        if state == .running {
            loop.paused = false
        }
    }
    
    private func breakIntentionalRetainCycle() {
        /// noop.
    }
    
    private func advance(by time: Double) {
        guard state == .running else { return }
        animation.advance(by: time)
        
        for handler in changeHandlers {
            handler(animation.value)
        }
        
        if animation.isFinished {
            complete(with: .finished)
        }
    }
    
    private func complete(with result: Result) {
        guard state == .running else { return }
        state = State.done(result: result)
        completionHandlers.forEach { $0(result) }
        completionHandlers.removeAll()
        changeHandlers.removeAll()
    }
    
    /// Adds a handler that will be called every time the animation's value changes.
    ///
    /// Newly added handlers are invoked immediately when they are added with
    /// the latest value from the animation.
    @discardableResult
    public func onChange(_ handler: @escaping (T.Result) -> Void) -> Animator<T> {
        switch state {
        case .running:
            changeHandlers.append(handler)
            handler(animation.value)
        case .done(_):
            break
        }
        return self
    }
    
    /// Adds a handler that will be called when the animation completes (in either
    /// a finished or cancelled state).
    ///
    /// If the animator is already in a completed state, the given handler
    /// will be called immediately.
    @discardableResult
    public func onCompletion(_ handler: @escaping (Result) -> Void) -> Animator<T> {
        switch state {
        case .running:
            completionHandlers.append(handler)
        case let .done(result):
            handler(result)
        }
        return self
    }
    
    /// Adds a handler that will be called when the animation completes in a
    /// finished state.
    ///
    /// If the animator is already in a finished state, the given handler
    /// will be called immediately.
    @discardableResult
    public func onFinish(_ handler: @escaping () -> Void) -> Animator<T> {
        onCompletion { (result) in
            guard result == .finished else { return }
            handler()
        }
        return self
    }
    
    /// Adds a handler that will be called when the animation completes in a
    /// cancelled state.
    ///
    /// If the animator is already in a cancelled state, the given handler
    /// will be called immediately.
    @discardableResult
    public func onCancel(_ handler: @escaping () -> Void) -> Animator<T> {
        onCompletion { (result) in
            guard result == .cancelled else { return }
            handler()
        }
        return self
    }
    
    /// Cancels the animation.
    ///
    /// If the animator is not in the `running` state, calls to `cancel()` will
    /// have no effect.
    public func cancel() {
        guard state == .running else { return }
        complete(with: .cancelled)
    }
    
}

public extension Animator {
    
    /// Represents the current state of an Animator.
    public enum State: Equatable {
        
        /// The animator is currently running the animation.
        case running
        
        /// The animator has completed (the animation is no longer running).
        case done(result: Result)
        
        public static func ==(lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.running, .running):
                return true
            case let (.done(l), .done(r)):
                return l == r
            default:
                return false
            }
        }
    }
}

public extension Animator {

    /// Represents the reason that the animator completed.
    public enum Result {
        
        /// The animation finished normally.
        case finished
        
        /// The animator was cancelled before the animation could finish.
        case cancelled
    }
    
}

public extension Animator {
    
    /// Assigns the changing output value of the animation to the given object
    /// and keypath on each frame.
    @discardableResult
    public func bind<Root>(to object: Root, keyPath: ReferenceWritableKeyPath<Root, T.Result>) -> Animator<T> {
        onChange { (value) in
            object[keyPath: keyPath] = value
        }
        return self
    }
    
}

public extension Animation {
    
    /// Initializes and returns an animator to execute this animation.
    ///
    /// The animator will begin running immediately.
    public func run() -> Animator<Self> {
        return Animator(animation: self)
    }
    
}
