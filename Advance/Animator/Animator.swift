/*

Copyright (c) 2016, Storehouse Media Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/// The state of an `Animator` instance.
public enum AnimatorState: Equatable {
    /// The animator has not yet started.
    case pending
    
    /// The animator is currently running.
    case running
    
    /// The animator has stopped running.
    case completed(AnimatorResult)
}

/// Equatable.
public func ==(lhs: AnimatorState, rhs: AnimatorState) -> Bool {
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

/// The possible result cases of an animator.
public enum AnimatorResult {
    /// The animator was cancelled before the animation completed.
    case cancelled
    
    /// The animator successfully ran the animation until it was finished.
    case finished
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
public final class Animator<A: AnimationType> {
    
    fileprivate lazy var subscription: LoopSubscription? = {
        
        let s = Loop.shared.subscribe()
        
        s.advanced.observe({ [unowned self] (elapsed) -> Void in
            guard self.state == .running else { return }
            self.animation.advance(elapsed)
            self.changed.fire(self.animation)
            if self.animation.finished == true {
                self.finish()
            }
        })
        
        return s
    }()
    
    /// The current state of the animator. Animators begin in a running state,
    /// and they are guarenteed to transition into either the cancelled or
    /// finished state exactly one time – no further state changes are allowed.
    fileprivate (set) public var state: AnimatorState = .pending {
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
                started.close(animation)
            case .completed(let result):
                switch result {
                case .cancelled:
                    cancelled.close(animation)
                case .finished:
                    finished.close(animation)
                }
            }
        }
    }
    
    /// The animation that is being run.
    fileprivate (set) public var animation: A
    
    /// Fired when the animator starts running
    public let started = Event<A>()
    
    /// Fired after every animation update.
    public let changed = Event<A>()
    
    /// Fired if the animator is cancelled.
    public let cancelled = Event<A>()
    
    /// Fired when the animation finishes.
    public let finished = Event<A>()
    
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
