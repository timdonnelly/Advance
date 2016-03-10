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

import UIKit
import Advance

final class GestureView: UIView {
    
    let animatableCenter = Animatable(value: CGPoint.zero)
    ;let animatableTransform = Animatable(value: SimpleTransform())
    
    private var centerWhenGestureBegan = CGPoint.zero
    private var transformWhenGestureBegan = SimpleTransform.zero
    
    private let recognizer = DirectManipulationGestureRecognizer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
        
        recognizer.addTarget(self, action: "manipulate:")
        addGestureRecognizer(recognizer)
        
        animatableCenter.changed.observe { [weak self] (c) -> Void in
            self?.center = c
        }
        
        animatableTransform.changed.observe { [weak self] (t) -> Void in
            self?.transform = t.affineTransform
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            animatableCenter.value = center
        }
    }
    
    private dynamic func manipulate(recognizer: DirectManipulationGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            
            // Take the anchor point into consideration
            let gestureLocation = recognizer.locationInView(self)
            let newCenter = superview!.convertPoint(gestureLocation, fromView: self)
            animatableCenter.value = newCenter
            
            var anchorPoint = gestureLocation
            anchorPoint.x /= bounds.width
            anchorPoint.y /= bounds.height
            layer.anchorPoint = anchorPoint
            
            animatableTransform.cancelAnimation()
            animatableCenter.cancelAnimation()
            centerWhenGestureBegan = animatableCenter.value
            transformWhenGestureBegan = animatableTransform.value
            break
        case .Changed:
            var t = transformWhenGestureBegan
            t.rotation += recognizer.rotation
            t.scale *= recognizer.scale
            animatableTransform.value = t
            
            var center = centerWhenGestureBegan
            center.x += recognizer.translationInView(superview).x
            center.y += recognizer.translationInView(superview).y
            animatableCenter.value = center
            
            break
        case .Ended, .Cancelled:
            // Reset the anchor point
            let mid = CGPoint(x: bounds.midX, y: bounds.midY)
            let newCenter = superview!.convertPoint(mid, fromView: self)
            animatableCenter.value = newCenter
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            var velocity = SimpleTransform.zero
            velocity.scale = recognizer.scaleVelocity
            velocity.rotation = recognizer.rotationVelocity
            var config = SpringConfiguration()
            config.threshold = 0.001
            animatableTransform.springTo(SimpleTransform(), initialVelocity: velocity, configuration: config)
            
            let centerVel = recognizer.translationVelocityInView(superview)
            var centerConfig = SpringConfiguration()
            centerConfig.tension = 40.0
            centerConfig.damping = 5.0
            let c = CGPoint(x: superview!.bounds.midX, y: superview!.bounds.midY)
            animatableCenter.springTo(c, initialVelocity: centerVel, configuration: centerConfig)
            break
        default:
            break
        }
    }
    
}
