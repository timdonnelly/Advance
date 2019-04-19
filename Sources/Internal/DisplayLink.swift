import Foundation

#if os(iOS) || os(tvOS)
import QuartzCore
#elseif os(macOS)
import CoreVideo
#endif


/// An object that produces an observable sequence of frames that are synchronized
/// to the device's display refresh rate. Provides a layer of abstraction to allow
/// for a consistent API between platforms.
final class DisplayLink {

    private let driver: Driver = Driver()
    
    /// Creates a new `DisplayLink` instance.
    ///
    /// The newly instantiated display link begins in a paused state.
    init() {}
    
    var onFrame: ((Frame) -> Void)? {
        get { return driver.onFrame }
        set { driver.onFrame = newValue }
    }
    
    
    /// Pauses the display link (no frames will be produced while paused is `true`).
    var isPaused: Bool {
        get { return driver.isPaused }
        set { driver.isPaused = newValue }
    }
    
}

extension DisplayLink {
    
    /// Info about a particular frame.
    struct Frame : Equatable {
        
        var previousTimestamp: Double
        
        /// The timestamp that the frame.
        var timestamp: Double
        
        /// The current duration between frames.
        var duration: Double {
            return timestamp - previousTimestamp
        }
    
    }
    
}




#if os(iOS) || os(tvOS) // iOS support using CADisplayLink --------------------------------------------------------

/// DisplayLink is used to hook into screen refreshes.
extension DisplayLink {
    
    fileprivate final class Driver {
    
        /// The callback to call for each frame.
        var onFrame: ((Frame) -> Void)? = nil
        
        /// If the display link is paused or not.
        var isPaused: Bool {
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
                self.onFrame?(frame)
            }
        }
        
        deinit {
            displayLink.invalidate()
        }
        
        /// The target for the CADisplayLink (because CADisplayLink retains its target).
        final class DisplayLinkTarget {
            
            /// The callback to call for each frame.
            var callback: ((DisplayLink.Frame) -> Void)? = nil
            
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

extension DisplayLink {
    
    /// DisplayLink is used to hook into screen refreshes.
    fileprivate final class Driver {
    
        /// The callback to call for each frame.
        var onFrame: ((Frame) -> Void)? = nil
        
        /// If the display link is paused or not.
        var isPaused: Bool = true {
            didSet {
                guard isPaused != oldValue else { return }
                if isPaused == true {
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
                let frame = DisplayLink.Frame(
                    previousTimestamp: inNow.pointee.timeInterval,
                    timestamp: inOutputTime.pointee.timeInterval)
                
                DispatchQueue.main.async {
                    self?.frame(frame)
                }
                
                return kCVReturnSuccess
            })

        }
        
        deinit {
            isPaused = true
        }
        
        /// Called for each CVDisplayLink frame callback.
        func frame(_ frame: Frame) {
            guard isPaused == false else { return }
            onFrame?(frame)
        }
    
    }
}
    
extension CVTimeStamp {
    fileprivate var timeInterval: TimeInterval {
        return TimeInterval(videoTime) / TimeInterval(self.videoTimeScale)
    }
}

#endif // ------------------------------------------------------------------------------------------
