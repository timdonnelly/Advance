import Foundation
import UIKit
import Advance

final class SpringView: UIView {
    
    let centerSpring = Spring(value: CGPoint.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
        
        let t = arc4random_uniform(120 - 20) + 20
        let d = arc4random_uniform(20 - 4) + 4
        
        centerSpring.tension = Scalar(t)
        centerSpring.damping = Scalar(d)
        
        centerSpring.values.observe { [unowned self] (c) -> Void in
            self.center = c
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
    }
    
}
