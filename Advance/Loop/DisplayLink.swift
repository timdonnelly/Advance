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
    }
}

func ==(lhs: DisplayLink.Frame, rhs: DisplayLink.Frame) -> Bool {
    return lhs.timestamp == rhs.timestamp && lhs.duration == rhs.duration
}


#if os(iOS) || os(tvOS) // iOS support using CADisplayLink --------------------------------------------------------

/// DisplayLink is used to hook into screen refreshes.
internal final class DisplayLink {
    
    /// The callback to call for each frame.
    var callback: ((_ frame: Frame) -> Void)? = nil
    
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
        var callback: ((_ frame: DisplayLink.Frame) -> Void)? = nil
        
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
    var callback: ((_ frame: Frame) -> Void)? = nil
    
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
