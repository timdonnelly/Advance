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
import UIKit.UIGestureRecognizerSubclass

private let π = CGFloat(M_PI)


public final class DirectManipulationGestureRecognizer: UIGestureRecognizer {
    
    public enum PinchDirection {
        case `in`
        case out
        case any
    }
    
    public var requiredPinchDirection: PinchDirection = .any
    
    // The state of the touches when we first saw them
    fileprivate var preliminaryState: GestureState = GestureState()
    
    // The state of the touches when the recognizer successfully began
    fileprivate var initialState: GestureState = GestureState()
    
    // The current and previous states, for reference.
    fileprivate var previousState: GestureState = GestureState()
    fileprivate var currentState: GestureState = GestureState()
    
    // As per the UIKit documentation, we don't retain the touches. But
    // we do remember their address so that we can compare against them as needed.
    fileprivate var firstTouchPointer: UnsafeMutableRawPointer? = nil
    fileprivate var secondTouchPointer: UnsafeMutableRawPointer? = nil
    
    fileprivate var previousCumulativeAngle: CGFloat = 0.0
    fileprivate var cumulativeAngle: CGFloat = 0.0
    
    fileprivate var lastUpdateTime: TimeInterval = 0.0
    fileprivate var lastUpdateDuration: TimeInterval = 0.0
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard state == .possible else { return }
        guard touches.count > 0 else { return }
        
        var touches = touches
        
        while touches.count > 0 {
            let t = touches.removeFirst()
            if firstTouchPointer == nil {
                firstTouchPointer = Unmanaged.passUnretained(t).toOpaque()
                let state = TouchState(t: t)
                preliminaryState.firstTouchState = state
                initialState.firstTouchState = state
                previousState.firstTouchState = state
                currentState.firstTouchState = state
            } else if secondTouchPointer == nil {
                secondTouchPointer = Unmanaged.passUnretained(t).toOpaque()
                let state = TouchState(t: t)
                preliminaryState.secondTouchState = state
                initialState.secondTouchState = state
                previousState.secondTouchState = state
                currentState.secondTouchState = state
            } else {
                continue
            }
        }
        
        if requiredPinchDirection == .any && firstTouchPointer != nil && secondTouchPointer != nil {
            begin()
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard state == .possible || state == .began || state == .changed else { return }
        
        previousState = currentState
        
        for t in touches {
            if Unmanaged.passUnretained(t).toOpaque() == firstTouchPointer {
                currentState.firstTouchState = TouchState(t: t)
            }
            
            if Unmanaged.passUnretained(t).toOpaque() == secondTouchPointer {
                currentState.secondTouchState = TouchState(t: t)
            }
        }
        
        // If either of the touches have just begun or ended, there's a good chance 
        // that we just began or ended the gesture. It turns out that setting the state
        // to .Changed stomps on the notification of the gesture beginning – so
        // from the target's perspective, the recognizer just start claiming to
        // have changed without going through a .Began phase. We can just check
        // to make sure that neither touch has just started or ended to avoid this.
        if currentState.firstTouchState.phase == .began || currentState.secondTouchState.phase == .began {
            return
        }
        
        if currentState.firstTouchState.phase == .ended || currentState.secondTouchState.phase == .ended {
            return
        }
        
        if currentState.firstTouchState.phase == .cancelled || currentState.secondTouchState.phase == .cancelled {
            return
        }
        
        if state == .possible {
            guard firstTouchPointer != nil && secondTouchPointer != nil else { return }
            
            // How far the user has pinched since we first saw the touches.
            let pinchDistance = currentState.distanceBetween - preliminaryState.distanceBetween
            
            switch requiredPinchDirection {
            case .any:
                begin()
            case .in:
                if pinchDistance > 0.0 {
                    begin()
                } else if pinchDistance < 0.0 {
                    state = .failed
                }
            case .out:
                if pinchDistance < 0.0 {
                    begin()
                } else if pinchDistance > 0.0 {
                    state = .failed
                }
            }
            
            if state == .possible && currentState.distanceTo(preliminaryState) > 4.0 {
                state = .failed
            }
            
            return
        }
        
        var angleDelta = currentState.angle - previousState.angle
        if (angleDelta > π) {
            angleDelta -= π*2.0;
        } else if (angleDelta < -π) {
            angleDelta += π*2.0;
        }
        
        previousCumulativeAngle = cumulativeAngle
        cumulativeAngle += angleDelta
        
        let currentTime = CACurrentMediaTime()
        lastUpdateDuration = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        assert(state == .began || state == .changed)
        state = .changed
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        
        
        for t in touches {
            if Unmanaged.passUnretained(t).toOpaque() == firstTouchPointer || Unmanaged.passUnretained(t).toOpaque() == secondTouchPointer {
                if state == .possible {
                    state = .failed
                } else if state == .began || state == .changed {
                    state = .cancelled
                }
                return
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        for t in touches {
            if Unmanaged.passUnretained(t).toOpaque() == firstTouchPointer || Unmanaged.passUnretained(t).toOpaque() == secondTouchPointer {
                if state == .possible {
                    state = .failed
                } else if state == .began || state == .changed {
                    state = .ended
                }
                return
            }
        }
    }
    
    fileprivate func begin() {
        guard state == .possible else { fatalError() }
        initialState = currentState
        previousState = currentState
        cumulativeAngle = 0.0
        previousCumulativeAngle = 0.0
        lastUpdateTime = CACurrentMediaTime()
        lastUpdateDuration = 0.0
        state = .began
    }
    
    override public func reset() {
        super.reset()
        
        firstTouchPointer = nil
        secondTouchPointer = nil
        
        preliminaryState = GestureState()
        initialState = GestureState()
        previousState = GestureState()
        currentState = GestureState()
    }
    
    
    public func translationInView(_ view: UIView?) -> CGPoint {
        let current = currentState.convertedToView(view)
        let initial = initialState.convertedToView(view)
        return current.center - initial.center
    }
    
    public func translationVelocityInView(_ view: UIView?) -> CGPoint {
        guard active else { return CGPoint.zero }
        guard lastUpdateDuration > 0.0 else { return CGPoint.zero }
        let current = currentState.convertedToView(view)
        let previous = previousState.convertedToView(view)
        var vel = current.center - previous.center
        vel.x /= CGFloat(lastUpdateDuration)
        vel.y /= CGFloat(lastUpdateDuration)
        return vel
    }
    
    public var rotation: CGFloat {
        guard active else { return 0.0 }
        return cumulativeAngle
    }
    
    public var rotationVelocity: CGFloat {
        guard active else { return 0.0 }
        guard lastUpdateDuration > 0.0 else { return 0.0 }
        let delta = cumulativeAngle - previousCumulativeAngle
        return delta / CGFloat(lastUpdateDuration)
    }
    
    public var scale: CGFloat {
        guard active else { return 1.0 }
        return currentState.distanceBetween / initialState.distanceBetween
    }
    
    public var scaleVelocity: CGFloat {
        guard active else { return 0.0 }
        guard lastUpdateDuration > 0.0 else { return 0.0 }
        let current = currentState.distanceBetween / initialState.distanceBetween
        let previous = previousState.distanceBetween / initialState.distanceBetween
        return ((current - previous) / CGFloat(lastUpdateDuration))
    }
    
    fileprivate var active: Bool {
        return state == .began || state == .changed || state == .ended
    }
}


private extension DirectManipulationGestureRecognizer {
    struct GestureState {
        var firstTouchState: TouchState = TouchState()
        var secondTouchState: TouchState = TouchState()
        
        
        func convertedToView(_ view: UIView?) -> GestureState {
            var s = self
            s.firstTouchState = s.firstTouchState.convertedToView(view)
            s.secondTouchState = s.secondTouchState.convertedToView(view)
            return s
        }
        
        func distanceTo(_ state: GestureState) -> CGFloat {
            return (state.center - center).distance
        }
        
        var distanceBetween: CGFloat {
            return delta.distance
        }
        
        var delta: CGPoint {
            return secondTouchState.location - firstTouchState.location
        }
        
        var angle: CGFloat {
            return delta.angle
        }
        
        var center: CGPoint {
            var p = CGPoint.zero
            p.x = firstTouchState.location.x + ((secondTouchState.location.x - firstTouchState.location.x) * 0.5)
            p.y = firstTouchState.location.y + ((secondTouchState.location.y - firstTouchState.location.y) * 0.5)
            return p
        }
    }
    
    struct TouchState {
        var location: CGPoint = CGPoint.zero
        var phase: UITouchPhase = UITouchPhase.began
        
        init() {}
        
        init(t: UITouch) {
            location = t.location(in: nil)
            phase = t.phase
        }
        
        func convertedToView(_ view: UIView?) -> TouchState {
            var s = self
            if let view = view {
                s.location = view.convert(s.location, from: nil)
            }
            return s
        }
        
        func distanceTo(_ state: TouchState) -> CGFloat {
            return (state.location - location).distance
        }
    }
}

private extension CGPoint {
    
    var angle: CGFloat {
        return atan2(y, x);
    }
    
    var distance: CGFloat {
        return sqrt((x*x) + (y*y))
    }
    
}

private func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    var result = CGPoint.zero
    result.x = lhs.x - rhs.x
    result.y = lhs.y - rhs.y
    return result
}
