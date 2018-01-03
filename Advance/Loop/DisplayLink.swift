import Foundation

#if os(iOS) || os(tvOS)
import QuartzCore
#elseif os(OSX)
import CoreVideo
#endif


extension DisplayLink {
    /// Info about a particular frame.
    struct Frame : Equatable {
        /// The timestamp that the frame.
        var timestamp: Double
        
        /// The current duration between frames.
        var duration: Double
        
        static func ==(lhs: Frame, rhs: Frame) -> Bool {
            return lhs.timestamp == rhs.timestamp
                && lhs.duration == rhs.duration
        }
        
    }
}




#if os(iOS) || os(tvOS) // iOS support using CADisplayLink --------------------------------------------------------

/// DisplayLink is used to hook into screen refreshes.
internal final class DisplayLink {
    
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
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        
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
        var callback: ((DisplayLink.Frame) -> Void)? = nil
        
        /// Called for each frame from the CADisplayLink.
        @objc dynamic func frame(_ displayLink: CADisplayLink) {
            callback?(Frame(timestamp: displayLink.timestamp, duration: displayLink.duration))
        }
    }
}

#elseif os(OSX) // OS X support using CVDisplayLink --------------------------------------------------

/// DisplayLink is used to hook into screen refreshes.
internal final class DisplayLink {
    
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
    
    var lastFrame = Frame(timestamp: 0, duration: 0)
    
    /// Creates a new paused DisplayLink instance.
    init() {
        func displayLinkOutputCallback(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, userInfo: UnsafeMutableRawPointer?) -> CVReturn {
            let timestamp = Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale) // convert to seconds
            let dl = unsafeBitCast(userInfo, to: DisplayLink.self) // cast back to a pointer to self
            
            let time = CVDisplayLinkGetNominalOutputVideoRefreshPeriod(displayLink)
            let duration = Double(Double(time.timeValue) / Double(time.timeScale)) // convert to seconds
            let info = Frame(timestamp: timestamp, duration: duration)
            
            // dispatch to main - this is called from an internal CV thread
            DispatchQueue.main.async { () -> Void in
                dl.frame(info) // call frame(timestamp:) on self
            }
            return kCVReturnSuccess
        }
        
        // hook up the frame output callback
        CVDisplayLinkSetOutputCallback(self.displayLink, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())) // pass in self as the 'userInfo'
    }
    
    deinit {
        paused = true
    }
    
    /// Called for each CVDisplayLink frame callback.
    func frame(_ frame: Frame) {
        guard paused == false else { return }
        guard frame.timestamp != lastFrame.timestamp else { return }
        callback?(frame)
        lastFrame = frame
    }
}

#endif // ------------------------------------------------------------------------------------------
