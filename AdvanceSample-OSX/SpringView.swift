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
        
        centerSpring.tension = Scalar(t)
        centerSpring.damping = Scalar(d)
        
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

