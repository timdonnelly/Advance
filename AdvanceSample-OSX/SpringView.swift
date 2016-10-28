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


final class SpringView : NSView, CALayerDelegate {
    let centerSpring = Spring(value: CGPoint.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wantsLayer = true
        
        layer?.backgroundColor = NSColor(calibratedRed: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        layer?.delegate = self
        
        let t = arc4random_uniform(120 - 20) + 20
        let d = arc4random_uniform(20 - 4) + 4
        
        centerSpring.configuration.tension = Scalar(t)
        centerSpring.configuration.damping = Scalar(d)
        
        centerSpring.changed.observe { [unowned self] (c) -> Void in
            self.layer?.position = c
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutSublayers(of layer: CALayer) {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
    }
}

