import Cocoa
import Advance


final class SpringContainerView : NSView, CALayerDelegate {
    
    @IBOutlet var tensionSlider: NSSlider!
    @IBOutlet var dampingSlider: NSSlider!
    
    let springView = SpringView(frame: CGRect(x: 0.0, y: 0.0, width: 24.0, height: 24.0))

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer?.delegate = self
        
        addSubview(springView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tensionSlider.doubleValue = springView.centerSpring.tension
        dampingSlider.doubleValue = springView.centerSpring.damping
    }
    
    override func layout() {
        super.layout()
        springView.centerSpring.reset(to: CGPoint(x: bounds.midX, y: bounds.midY))
        springView.frame = springView.layer!.frame

    }
    
    override func mouseDown(with theEvent: NSEvent) {
        var point = theEvent.locationInWindow
        point.x -= (springView.bounds.width / 2.0)
        point.y -= (springView.bounds.height / 2.0)
        springView.centerSpring.target = point
    }
    
    @IBAction func tensionChanged(_ sender: AnyObject) {
        springView.centerSpring.tension = tensionSlider.doubleValue
    }
    
    @IBAction func dampingSlider(_ sender: AnyObject) {
        springView.centerSpring.damping = dampingSlider.doubleValue
    }
}
