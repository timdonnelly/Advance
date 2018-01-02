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
    
    fileprivate typealias Observer = (Double)->Void
    
    /// The default loop.
    public static let shared = Loop()
    
    fileprivate var currentAnimationTime: Double = 0.0
    
    fileprivate lazy var displayLink: DisplayLink = {
        let link = DisplayLink()
        link.callback = { [unowned self] (frame) in
            self.displayLinkDidFire(frame)
        }
        return link
    }()
    
    private var observers: [UUID:Observer] = [:]
    
    fileprivate init() {

    }
    
    /// Generates and returns a subscription for this loop.
    ///
    /// **Note that loops are retained by subscriptions.**
    public func subscribe() -> Subscription {
        return Subscription(loop: self)
    }
    
    fileprivate func observe(with observer: @escaping Observer) -> UUID {
        let identifier = UUID()
        observers[identifier] = observer
        startIfNeeded()
        return identifier
    }
    
    fileprivate func removeObserver(for token: UUID) {
        observers.removeValue(forKey: token)
        stopIfPossible()
    }
    
    fileprivate func startIfNeeded() {
        guard observers.count > 0 else { return }
        guard displayLink.paused == true else { return }
        displayLink.paused = false
        currentAnimationTime = 0
    }
    
    fileprivate func stopIfPossible() {
        guard observers.count == 0 else { return }
        guard displayLink.paused == false else { return }
        displayLink.paused = true
    }
    
    fileprivate func displayLinkDidFire(_ frame: DisplayLink.Frame) {
        
        let timestamp = max(frame.timestamp, currentAnimationTime)
        
        if currentAnimationTime == 0.0 {
            currentAnimationTime = timestamp - frame.duration
        }
        
        let elapsed = timestamp - currentAnimationTime
        currentAnimationTime = timestamp
        
        let observers = self.observers.values
        
        // Loop through once to let everything update the animation state...
        for observer in observers {
            observer(elapsed)
        }
        
    }
}


public extension Loop {
    
    /// The interface through which consumers can respond to animation loop updates.
    public final class Subscription {
        
        private var observationToken: UUID? = nil
        
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
                    unsubscribe()
                } else {
                    subscribe()
                }
            }
        }
        
        fileprivate init(loop: Loop) {
            self.loop = loop
        }
        
        deinit {
            unsubscribe()
        }
        
        fileprivate func advance(_ elapsed: Double) {
            advanced.fire(value: elapsed)
        }
        
        private func subscribe() {
            guard observationToken == nil else { return }
            observationToken = loop.observe(with: { [unowned self] (time) in
                self.advance(time)
            })
        }
        
        private func unsubscribe() {
            guard let token = observationToken else { return }
            loop.removeObserver(for: token)
            observationToken = nil
        }
        
    }
    
}


