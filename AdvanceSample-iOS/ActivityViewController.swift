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

class ActivityViewController: DemoViewController {
    
    let activityView = ActivityView()
    
    let slider = UISlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Logo"
        note = "Drag the slider to disassemble."
                
        activityView.flashing = true
        contentView.addSubview(activityView)
        
        contentView.addSubview(slider)
        slider.alpha = 0.0
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        slider.minimumTrackTintColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = min(view.bounds.width, view.bounds.height) * 0.6
        activityView.bounds.size = CGSize(width: size, height: size)
        activityView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        let sliderInset = CGFloat(32.0)
        
        var sliderFrame = CGRect.zero
        sliderFrame.size.width = view.bounds.width - sliderInset*2.0
        sliderFrame.size.height = 44.0
        sliderFrame.origin.x = sliderInset
        sliderFrame.origin.y = view.bounds.maxY - sliderInset - 44.0
        slider.frame = sliderFrame
    }
    
    dynamic func sliderChanged() {
        activityView.assembledAmount = CGFloat(slider.value)
        activityView.flashing = activityView.assembledAmount == 1.0
    }
    
    override func didEnterFullScreen() {
        super.didEnterFullScreen()
        slider.alpha = 1.0
    }
    
    override func didLeaveFullScreen() {
        super.didLeaveFullScreen()
        slider.alpha = 0.0
    }

}
