/// Runs an animation until it is either finished or cancelled.
/// Animators cannot be reused:
/// - They begin in a 'running' state
/// - If the animation finishes, the animator enters the `completed (finished)` state.
/// - If `cancel()` is called on the animator while in a running state, the
///   animator enters the `completed (cancelled)` state.
public final class Animator<Element> {

    private (set) public var state: State

    private var animation: AnyAnimation<Element>
    private let loop: Loop
    private let valueSink: Sink<Element>
    
    private var completionHandlers: [(Result) -> Void]
    
    /// Instantiates a new animator for the given animation.
    /// The animator begins running immediately.
    public init<T>(animation: T) where T: Animation, T.Element == Element {
        self.animation = AnyAnimation(animation)
        self.state = State.running
        self.loop = Loop()
        self.completionHandlers = []
        self.valueSink = Sink()
        
        if animation.isFinished {
            self.state = State.done(result: .finished)
        }
        
        loop.observe { [weak self] (frame) in
            self?.advance(by: frame.duration)
        }
        
        if state == .running {
            loop.paused = false
        }
    }
    
    deinit {
        cancel()
    }
    
    
    private func advance(by time: Double) {
        guard state == .running else { return }
        
        animation.advance(by: time)
        
        valueSink.send(value: animation.value)
        
        if animation.isFinished {
            complete(with: .finished)
        }
    }
    
    private func complete(with result: Result) {
        guard state == .running else { return }
        state = State.done(result: result)
        completionHandlers.forEach { $0(result) }
        completionHandlers.removeAll()
    }
    
    /// Adds a handler that will be called every time the animation's value changes.
    ///
    /// Newly added handlers are invoked immediately when they are added with
    /// the latest value from the animation.
    @discardableResult
    public func onChange(_ handler: @escaping (Element) -> Void) -> Animator<Element> {
        switch state {
        case .running:
            valueSink.observe(handler)
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
    public func onCompletion(_ handler: @escaping (Result) -> Void) -> Animator<Element> {
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
    public func onFinish(_ handler: @escaping () -> Void) -> Animator<Element> {
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
    public func onCancel(_ handler: @escaping () -> Void) -> Animator<Element> {
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

extension Animator: Observable {
    
    @discardableResult
    public func observe(_ observer: @escaping (Element) -> Void) -> Subscription {
        return valueSink.observe(observer)
    }
    
}

public extension Animator {
    
    public func bound<T>(to object: T, keyPath: ReferenceWritableKeyPath<T, Element>) -> Animator<Element> {
        observe { (nextValue) in
            object[keyPath: keyPath] = nextValue
        }
        return self
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


public extension Animation {
    
    /// Initializes and returns an animator to execute this animation.
    ///
    /// The animator will begin running immediately.
    public func run() -> Animator<Self.Element> {
        return Animator(animation: self)
    }
    
}
