import Cocoa
import Advance


final class SpringView : NSView, CALayerDelegate {
    let centerSpring = Spring(initialValue: CGPoint.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wantsLayer = true
        
        layer?.backgroundColor = NSColor(calibratedRed: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        layer?.delegate = self
        
        let t = arc4random_uniform(120 - 20) + 20
        let d = arc4random_uniform(20 - 4) + 4
        
        centerSpring.tension = Double(t)
        centerSpring.damping = Double(d)
        centerSpring.onChange = { [weak self] point in self?.layer!.position = point }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        layer?.cornerRadius = min(bounds.width, bounds.height) / 2.0
    }
        
}

