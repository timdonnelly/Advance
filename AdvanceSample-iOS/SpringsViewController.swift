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
import UIKit
import Advance

class SpringsViewController: DemoViewController {
    
    fileprivate let springView = SpringView()
    
    fileprivate let configView = SpringConfigurationView()
    
    fileprivate let tapRecognizer = UITapGestureRecognizer()
    
    required init() {
        super.init(nibName: nil, bundle:    nil)
        title = "Spring"
        note = "Tap anywhere to move the dot using a spring."
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector(tap(_:)))
        tapRecognizer.isEnabled = false
        
        springView.bounds = CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0)
        
        configView.delegate = self
        configView.alpha = 0.0
        contentView.addSubview(springView)
        contentView.addSubview(configView)
        
        updateSprings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var configFrame = CGRect.zero
        configFrame.size.width = view.bounds.width
        configFrame.size.height = configView.sizeThatFits(view.bounds.size).height
        configFrame.origin.y = view.bounds.maxY - configFrame.height - bottomLayoutGuide.length
        configView.frame = configFrame
    }
    
    @objc dynamic func tap(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: view)
        springView.centerSpring.target = point
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        springView.centerSpring.reset(to: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
    }
    
    fileprivate func updateSprings() {
        springView.centerSpring.configuration.tension = Scalar(configView.tension)
        springView.centerSpring.configuration.damping = Scalar(configView.damping)
    }
    
    override func didEnterFullScreen() {
        super.didEnterFullScreen()
        configView.alpha = 1.0
        tapRecognizer.isEnabled = true
    }
    
    override func didLeaveFullScreen() {
        super.didLeaveFullScreen()
        configView.alpha = 0.0
        springView.centerSpring.target = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY)
        tapRecognizer.isEnabled = false
    }
}


extension SpringsViewController: SpringConfigurationViewDelegate {
    func springConfigurationViewDidChange(_ view: SpringConfigurationView) {
        updateSprings()
    }
}
