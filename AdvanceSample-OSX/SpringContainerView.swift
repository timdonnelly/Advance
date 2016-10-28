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

import Cocoa
import Advance


final class SpringContainerView : NSView, CALayerDelegate {
    
    @IBOutlet var tensionSlider: NSSlider!
    @IBOutlet var dampingSlider: NSSlider!
    
    var springView = SpringView(frame: CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0))

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.cgColor
        layer?.delegate = self
        
        addSubview(springView)
        springView.centerSpring.reset(CGPoint(x: bounds.midX, y: bounds.midY))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tensionSlider.doubleValue = springView.centerSpring.configuration.tension
        dampingSlider.doubleValue = springView.centerSpring.configuration.damping
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        var point = theEvent.locationInWindow
        point.x -= (springView.bounds.width / 2.0)
        point.y -= (springView.bounds.height / 2.0)
        springView.centerSpring.target = point
    }
    
    @IBAction func tensionChanged(_ sender: AnyObject) {
        springView.centerSpring.configuration.tension = tensionSlider.doubleValue
    }
    
    @IBAction func dampingSlider(_ sender: AnyObject) {
        springView.centerSpring.configuration.damping = dampingSlider.doubleValue
    }
}
