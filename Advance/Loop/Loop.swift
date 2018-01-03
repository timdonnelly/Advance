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


