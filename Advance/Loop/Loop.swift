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

import Foundation
import QuartzCore


/// The animation loop that powers all of the Animation framework.
public final class Loop {
    
    /// The default loop.
    public static let shared = Loop()
    
    private var currentAnimationTime: Double = 0.0
    
    private lazy var displayLink: DisplayLink = {
        let link = DisplayLink()
        link.callback = { [unowned self] (frame) in
            self.displayLinkDidFire(frame)
        }
        return link
    }()
    
    private var tokens: Set<LoopSubscription.Token> = []
    
    /// All currently active subscriptions.
    public var subscriptions: [LoopSubscription] {
        return tokens.filter({$0.subscription != nil}).map({ $0.subscription! })
    }
    
    private init() {

    }
    
    /// Generates and returns a subscription for this loop.
    ///
    /// **Note that loops are retained by subscriptions.**
    public func subscribe() -> LoopSubscription {
        return LoopSubscription(loop: self)
    }
    
    private func add(subscription: LoopSubscription) {
        assert(subscription.loop === self)
        tokens.insert(subscription.token)
        startIfNeeded()
    }
    
    private func remove(subscription: LoopSubscription) {
        assert(subscription.loop === self)
        tokens.remove(subscription.token)
        stopIfPossible()
    }
    
    private func startIfNeeded() {
        guard tokens.count > 0 else { return }
        guard displayLink.paused == true else { return }
        displayLink.paused = false
        currentAnimationTime = 0
    }
    
    private func stopIfPossible() {
        guard tokens.count == 0 else { return }
        guard displayLink.paused == false else { return }
        displayLink.paused = true
    }
    
    private func displayLinkDidFire(frame: DisplayLink.Frame) {
        
        let timestamp = max(frame.timestamp, currentAnimationTime)
        
        if currentAnimationTime == 0.0 {
            currentAnimationTime = timestamp - frame.duration
        }
        
        let elapsed = timestamp - currentAnimationTime
        currentAnimationTime = timestamp
        
        let t = tokens
        
        // Loop through once to let everything update the animation state...
        for token in t {
            guard token.subscription != nil else {
                tokens.remove(token)
                continue
            }
            token.subscription?.advance(elapsed)
        }
        
        stopIfPossible()
    }
}

/// The interface through which consumers can respond to animation loop updates.
public final class LoopSubscription {
    
    private final class Token: Hashable {
        weak var subscription: LoopSubscription?
        init(subscription: LoopSubscription) {
            self.subscription = subscription
        }
        var hashValue: Int {
            return unsafeAddressOf(self).hashValue
        }
    }
    
    private lazy var token: Token = {
        return Token(subscription: self)
    }()
    
    /// Fired during the update phase of each turn of the loop. Contains
    /// the elapsed time for the current animation frame.
    public let advanced = Event<Double>()
    
    /// The associated loop instance.
    public let loop: Loop
    
    /// Any time animation updates are not required, the subscription should
    /// be paused for efficiency.
    public var paused: Bool = true {
        didSet {
            guard paused != oldValue else { return }
            if paused {
                loop.remove(self)
            } else {
                loop.add(self)
            }
        }
    }
    
    private init(loop: Loop) {
        self.loop = loop
    }
    
    deinit {
        paused = true
    }
    
    private func advance(elapsed: Double) {
        advanced.fire(elapsed)
    }
}

private func ==(lhs: LoopSubscription.Token, rhs: LoopSubscription.Token) -> Bool {
    return lhs === rhs
}