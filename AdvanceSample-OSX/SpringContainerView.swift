import Cocoa
import Advance


final class SpringContainerView : NSView, CALayerDelegate {
    
    @IBOutlet var tensionSlider: NSSlider!
    @IBOutlet var dampingSlider: NSSlider!
    
    var springView = SpringView(frame: CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0))

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.cgColor
        layer?.delegate = self
        
        addSubview(springView)
        springView.centerSpring.reset(to: CGPoint(x: bounds.midX, y: bounds.midY))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tensionSlider.doubleValue = springView.centerSpring.configuration.tension
        dampingSlider.doubleValue = springView.centerSpring.configuration.damping
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        var point = theEvent.locationInWindow
        point.x -= (springView.bounds.width / 2.0)
        point.y -= (springView.bounds.height / 2.0)
        springView.centerSpring.target = point
    }
    
    @IBAction func tensionChanged(_ sender: AnyObject) {
        springView.centerSpring.configuration.tension = tensionSlider.doubleValue
    }
    
    @IBAction func dampingSlider(_ sender: AnyObject) {
        springView.centerSpring.configuration.damping = dampingSlider.doubleValue
    }
}
