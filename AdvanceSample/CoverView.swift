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

final class CoverView: UIView {
    
    let logoView: UIImageView
    
    let urlLabel: UILabel
    
    var URLVisibility: CGFloat = 1.0 {
        didSet {
            urlLabel.alpha = URLVisibility
        }
    }
    
    override init(frame: CGRect) {
        logoView = UIImageView(image: UIImage(named: "logo"))
        logoView.tintColor = UIColor.whiteColor()
        logoView.sizeToFit()
        
        urlLabel = UILabel(frame: CGRect.zero)
        
        var attribs: [String: AnyObject] = [:]
        attribs[NSFontAttributeName] = UIFont.systemFontOfSize(12.0, weight: UIFontWeightRegular)
        attribs[NSForegroundColorAttributeName] = UIColor.whiteColor()
        
        // attribs[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
        
        urlLabel.attributedText = NSAttributedString(string: "github.com/storehouse/Advance", attributes: attribs)
        urlLabel.sizeToFit()
        
        super.init(frame: frame)
        
        addSubview(logoView)
        addSubview(urlLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logoView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        urlLabel.center = CGPoint(x: bounds.midX, y: logoView.frame.maxY + 4.0 + urlLabel.bounds.height/2.0)
    }
    
}
