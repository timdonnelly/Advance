public final class Animator<T> where T: Animation {

    private (set) public var state: State

    private var animation: T
    private let loop: Loop
    private let valueSink: Sink<T.Result>
    
    private var completionHandlers: [(Result) -> Void]
    private var changeHandlers: [(T.Result) -> Void]
    
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
    
    @discardableResult
    public func onChange(_ handler: @escaping (T.Result) -> Void) -> Animator<T> {
        switch state {
        case .running:
            changeHandlers.append(handler)
        case .done(_):
            break
        }
        return self
    }
    
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
    
    @discardableResult
    public func onFinish(_ handler: @escaping () -> Void) -> Animator<T> {
        onCompletion { (result) in
            guard result == .finished else { return }
            handler()
        }
        return self
    }
    
    @discardableResult
    public func onCancel(_ handler: @escaping () -> Void) -> Animator<T> {
        onCompletion { (result) in
            guard result == .cancelled else { return }
            handler()
        }
        return self
    }
    
    public func cancel() {
        guard state == .running else { return }
        complete(with: .cancelled)
    }
    
    public var isRunning: Bool {
        if case .running = state {
            return true
        }
        return false
    }
    
    public var isCancelled: Bool {
        switch state {
        case .running:
            return false
        case let .done(result):
            return result == .cancelled
        }
    }
    
    public var isFinished: Bool {
        switch state {
        case .running:
            return false
        case let .done(result):
            return result == .finished
        }
    }
    
    
}

public extension Animator {
    
    public enum State: Equatable {
        
        case running
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

    public enum Result {
        case finished
        case cancelled
    }
    
}

public extension Animator {
    
    @discardableResult
    public func bind<Root>(to object: Root, keyPath: ReferenceWritableKeyPath<Root, T.Result>) -> Animator<T> {
        onChange { (value) in
            object[keyPath: keyPath] = value
        }
        return self
    }
    
}

public extension Animation {
    
    public func run() -> Animator<Self> {
        return Animator(animation: self)
    }
    
}
