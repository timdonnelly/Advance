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

class GravityViewController: DemoViewController {
    
    var simulation = GravitySimulation() {
        didSet {
            if simulation.settled == false && subscription.paused == true {
                subscription.paused = false
            }
            view.setNeedsLayout()
        }
    }
    
    fileprivate lazy var subscription: Loop.Subscription = {
        let s = Loop.shared.subscribe()
        
        s.advanced.observe({ [unowned self] (elapsed) -> Void in
            self.simulation.advance(by: elapsed)
            if self.simulation.settled {
                self.subscription.paused = true
            }
        })
        
        return s
    }()
    
    let resetButton = UIButton()
    
    fileprivate var nodeLayers: [[CALayer]] = []
    
    fileprivate var lastLayoutSize: CGSize = CGSize.zero
    
    fileprivate let recognizer = UILongPressGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Gravity"
        note = "Long press to add gravity."
        
        recognizer.minimumPressDuration = 0.3
        recognizer.addTarget(self, action: #selector(press(_:)))
        recognizer.isEnabled = false
        contentView.addGestureRecognizer(recognizer)
        
        resetButton.setTitle("Reset", for: UIControlState())
        resetButton.setTitleColor(UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0), for: UIControlState())
        resetButton.layer.cornerRadius = 4.0
        resetButton.tintColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
        resetButton.layer.borderColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        resetButton.layer.borderWidth = 1.0
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        resetButton.alpha = 0.0
        view.addSubview(resetButton)
        
        
        for r in 0..<simulation.rows {
            nodeLayers.append([])
            for _ in 0..<simulation.cols {
                let layer = CALayer()
                layer.backgroundColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0).cgColor
                layer.bounds = CGRect(x: 0.0, y: 0.0, width: 8.0, height: 8.0)
                layer.cornerRadius = 4.0
                layer.actions = ["position": NSNull()]
                nodeLayers[r].append(layer)
                contentView.layer.addSublayer(layer)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.bounds.size != lastLayoutSize {
            lastLayoutSize = view.bounds.size
            reset()
        }
        
        for r in 0..<simulation.rows {
            for c in 0..<simulation.cols {
                let position = simulation.getPosition(row: r, col: c)
                nodeLayers[r][c].position = position
            }
        }
        
        resetButton.bounds = CGRect(x: 0.0, y: 0.0, width: 120.0, height: 44.0)
        resetButton.center = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.maxY - 64.0)
    }
    
    @objc dynamic func press(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            simulation.target = recognizer.location(in: view)
        case .ended:
            simulation.target = nil
        default:
            break
        }
    }
    
    @objc dynamic func reset() {
        simulation.reset(layoutBounds: view.bounds.insetBy(dx: 64.0, dy: 128.0))
    }
    
    override func didEnterFullScreen() {
        super.didEnterFullScreen()
        recognizer.isEnabled = true
        resetButton.alpha = 1.0
    }
    
    override func didLeaveFullScreen() {
        super.didLeaveFullScreen()
        recognizer.isEnabled = false
        resetButton.alpha = 0.0
    }
}
