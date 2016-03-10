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

class DemoViewController: UIViewController {
    
    var note: String {
        get { return noteLabel.text ?? "" }
        set {
            noteLabel.text = newValue
            view.setNeedsLayout()
        }
    }
    
    override var title: String? {
        didSet {
            titleLabel.text = title
            view.setNeedsLayout()
        }
    }
    
    let contentView = UIView()
    
    private let titleLabel = UILabel()
    
    private let noteLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        contentView.alpha = 0.4
        contentView.layer.allowsGroupOpacity = false
        contentView.userInteractionEnabled = false
        contentView.frame = view.bounds
        view.addSubview(contentView)
        
        titleLabel.font = UIFont.systemFontOfSize(32.0, weight: UIFontWeightMedium)
        titleLabel.textColor = UIColor.darkGrayColor()
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        noteLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightThin)
        noteLabel.textColor = UIColor.darkGrayColor()
        noteLabel.textAlignment = .Center
        noteLabel.numberOfLines = 0
        noteLabel.alpha = 0.0
        view.addSubview(noteLabel)
    }
    
    final var fullScreen = false {
        didSet {
            guard fullScreen != oldValue else { return }
            
            UIView.animateWithDuration(0.4) {
                if self.fullScreen {
                    self.didEnterFullScreen()
                } else {
                    self.didLeaveFullScreen()
                }
            }
        }
    }
    
    func didEnterFullScreen() {
        noteLabel.alpha = 1.0
        contentView.alpha = 1.0
        contentView.userInteractionEnabled = true
        titleLabel.alpha = 0.0
    }
    
    func didLeaveFullScreen() {
        noteLabel.alpha = 0.0
        contentView.alpha = 0.5
        contentView.userInteractionEnabled = false
        titleLabel.alpha = 1.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.frame = view.bounds
        
        let labelHeight = noteLabel.sizeThatFits(CGSize(width: view.bounds.width-64.0, height: CGFloat.max)).height
        var labelFrame = CGRect.zero
        labelFrame.origin.x = 32.0
        labelFrame.origin.y = 32.0
        labelFrame.size.width = view.bounds.width - 64.0
        labelFrame.size.height = labelHeight
        noteLabel.frame = labelFrame
        
        let titleHeight = titleLabel.sizeThatFits(CGSize(width: view.bounds.width-64.0, height: CGFloat.max)).height
        var titleFrame = CGRect.zero
        titleFrame.origin.x = 32.0
        titleFrame.origin.y = 32.0
        titleFrame.size.width = view.bounds.width - 64.0
        titleFrame.size.height = titleHeight
        titleLabel.frame = titleFrame
    }
    
}
