import Foundation

#if os(iOS) || os(tvOS)
import QuartzCore
#elseif os(macOS)
import CoreVideo
#endif


/// An object that produces an observable sequence of frames that are synchronized
/// to the device's display refresh rate.
public final class Loop {
    
    fileprivate let frameSink: Sink<Frame>
    
    private let driver: Driver
    
    /// Creates a new loop.
    ///
    /// The newly instantiated loop begins in a paused state.
    public init() {
        frameSink = Sink()
        driver = Driver()
        driver.callback = { [unowned self] frame in
            self.frameSink.send(value: frame)
        }
    }
    
    /// Pauses the loop (no frames will be produced while paused is `true`).
    public var paused: Bool {
        get { return driver.paused }
        set { driver.paused = newValue }
    }
    
}

extension Loop: Observable {
    
    @discardableResult
    public func observe(_ observer: @escaping (Frame) -> Void) -> Subscription {
        return frameSink.observe(observer)
    }
    
}


public extension Loop {
    /// Info about a particular frame.
    public struct Frame : Equatable {
        
        public var previousTimestamp: Double
        
        /// The timestamp that the frame.
        public var timestamp: Double
        
        /// The current duration between frames.
        public var duration: Double {
            return timestamp - previousTimestamp
        }
        
        public static func ==(lhs: Frame, rhs: Frame) -> Bool {
            return lhs.timestamp == rhs.timestamp
                && lhs.previousTimestamp == rhs.previousTimestamp
        }
        
    }
}




#if os(iOS) || os(tvOS) // iOS support using CADisplayLink --------------------------------------------------------

/// DisplayLink is used to hook into screen refreshes.
fileprivate extension Loop {
    
    final class Driver {
    
        /// The callback to call for each frame.
        var callback: ((Frame) -> Void)? = nil
        
        /// If the display link is paused or not.
        var paused: Bool {
            get {
                return displayLink.isPaused
            }
            set {
                displayLink.isPaused = newValue
            }
        }
        
        /// The CADisplayLink that powers this DisplayLink instance.
        let displayLink: CADisplayLink
        
        /// The target for the CADisplayLink (because CADisplayLink retains its target).
        let target = DisplayLinkTarget()
        
        /// Creates a new paused DisplayLink instance.
        init() {
            displayLink = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
            displayLink.isPaused = true
            displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            
            target.callback = { [unowned self] (frame) in
                self.callback?(frame)
            }
        }
        
        deinit {
            displayLink.invalidate()
        }
        
        /// The target for the CADisplayLink (because CADisplayLink retains its target).
        internal final class DisplayLinkTarget {
            
            /// The callback to call for each frame.
            var callback: ((Loop.Frame) -> Void)? = nil
            
            /// Called for each frame from the CADisplayLink.
            @objc dynamic func frame(_ displayLink: CADisplayLink) {

                let timestamp: TimeInterval

                if #available(iOS 10.0, *) {
                    timestamp = displayLink.targetTimestamp
                } else {
                    timestamp = displayLink.timestamp + displayLink.duration
                }

                let frame = Frame(
                    previousTimestamp: displayLink.timestamp,
                    timestamp: timestamp)

                callback?(frame)
            }
        }
        
    }
}

#elseif os(macOS) // macOS support using CVDisplayLink --------------------------------------------------

fileprivate extension Loop {
    
    /// DisplayLink is used to hook into screen refreshes.
    final class Driver {
    
        /// The callback to call for each frame.
        var callback: ((Frame) -> Void)? = nil
        
        /// If the display link is paused or not.
        var paused: Bool = true {
            didSet {
                guard paused != oldValue else { return }
                if paused == true {
                    CVDisplayLinkStop(self.displayLink)
                } else {
                    CVDisplayLinkStart(self.displayLink)
                }
            }
        }
        
        /// The CVDisplayLink that powers this DisplayLink instance.
        var displayLink: CVDisplayLink = {
            var dl: CVDisplayLink? = nil
            CVDisplayLinkCreateWithActiveCGDisplays(&dl)
            return dl!
        }()
                
        init() {
            
            CVDisplayLinkSetOutputHandler(self.displayLink, { [weak self] (displayLink, inNow, inOutputTime, flageIn, flagsOut) -> CVReturn in
                let frame = Loop.Frame(
                    previousTimestamp: inNow.pointee.timeInterval,
                    timestamp: inOutputTime.pointee.timeInterval)
                
                DispatchQueue.main.async {
                    self?.frame(frame)
                }
                
                return kCVReturnSuccess
            })

        }
        
        deinit {
            paused = true
        }
        
        /// Called for each CVDisplayLink frame callback.
        func frame(_ frame: Frame) {
            guard paused == false else { return }
            callback?(frame)
        }
    
    }
}
    
fileprivate extension CVTimeStamp {
    var timeInterval: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(self.videoTimeScale)
    }
}

#endif // ------------------------------------------------------------------------------------------
