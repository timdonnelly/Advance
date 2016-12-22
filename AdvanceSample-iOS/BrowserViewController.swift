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

private final class DemoItem: BrowserItem {
    let viewController: DemoViewController
    init(viewController: DemoViewController) {
        self.viewController = viewController
        super.init()
    }
}

final class BrowserViewController: UIViewController {
    
    let viewControllers: [DemoViewController]
    
    let backgroundImageView = UIImageView(frame: CGRect.zero)
    let blurredBackgroundImageView = UIImageView(frame: CGRect.zero)
    let backgroundDimmingView = UIView(frame: CGRect.zero)
    
    let blurSpring = Spring(value: CGFloat.zero)
    
    let browserView = BrowserView(frame: CGRect.zero)
    
    required init(viewControllers: [DemoViewController]) {
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
        
        var cfg = SpringConfiguration()
        cfg.threshold = 0.001
        cfg.tension = 60.0
        cfg.damping = 26.0
        blurSpring.configuration = cfg
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "background")
        view.addSubview(backgroundImageView)
        
        blurredBackgroundImageView.contentMode = .scaleAspectFill
        blurredBackgroundImageView.image = UIImage(named: "background-blurred")
        blurredBackgroundImageView.alpha = 0.0
        view.addSubview(blurredBackgroundImageView)
        
        backgroundDimmingView.backgroundColor = UIColor.black
        backgroundDimmingView.alpha = 0.3
        view.addSubview(backgroundDimmingView)
        
        let cv = CoverView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))
        browserView.coverView = cv
            
        
        
        view.addSubview(browserView)
        browserView.delegate = self
        
        browserView.items = viewControllers.map({ (vc) -> DemoItem in
            return DemoItem(viewController: vc)
        })
        
        blurSpring.changed.observe { [unowned self] (b) in
            self.blurredBackgroundImageView.alpha = b
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.frame = view.bounds
        blurredBackgroundImageView.frame = view.bounds
        backgroundDimmingView.frame = view.bounds
        browserView.frame = view.bounds
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

extension BrowserViewController: BrowserViewDelegate {
    func browserView(_ browserView: BrowserView, didShowItem item: BrowserItem) {
        guard let item = item as? DemoItem else { fatalError() }
        assert(item.viewController.parent != self)
        addChildViewController(item.viewController)
        item.viewController.view.frame = item.view.bounds
        item.view.addSubview(item.viewController.view)
        item.viewController.didMove(toParentViewController: self)
    }
    
    func browserView(_ browserView: BrowserView, didHideItem item: BrowserItem) {
        guard let item = item as? DemoItem else { fatalError() }
        assert(item.viewController.parent == self)
        item.viewController.willMove(toParentViewController: nil)
        item.viewController.view.removeFromSuperview()
        item.viewController.removeFromParentViewController()
    }
    
    func browserView(_ browserView: BrowserView, didEnterFullScreenForItem item: BrowserItem) {
        guard let item = item as? DemoItem else { fatalError() }
        item.viewController.fullScreen = true

    }
    
    func browserView(_ browserView: BrowserView, didLeaveFullScreenForItem item: BrowserItem) {
        guard let item = item as? DemoItem else { fatalError() }
        item.viewController.fullScreen = false
    }
    
    func browserViewDidScroll(_ browserView: BrowserView) {
        var blurAmount = browserView.currentIndex
        blurAmount = min(blurAmount, 1.0)
        blurAmount = max(blurAmount, 0.0)
        blurSpring.target = blurAmount
    }
}
