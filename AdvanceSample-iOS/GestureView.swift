import UIKit
import Advance

final class GestureView: UIView {
    
    let animatableCenter = Spring(value: CGPoint.zero)
    let animatableTransform = Spring(value: SimpleTransform())
    
    fileprivate var centerWhenGestureBegan = CGPoint.zero
    fileprivate var transformWhenGestureBegan = SimpleTransform.zero
    
    fileprivate let recognizer = DirectManipulationGestureRecognizer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
        
        recognizer.addTarget(self, action: #selector(manipulate(_:)))
        addGestureRecognizer(recognizer)
        
        animatableCenter.changed.observe { [weak self] (c) -> Void in
            self?.center = c
        }
        
        animatableTransform.changed.observe { [weak self] (t) -> Void in
            self?.transform = t.affineTransform
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            animatableCenter.reset(to: center)
        }
    }
    
    @objc fileprivate dynamic func manipulate(_ recognizer: DirectManipulationGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            // Take the anchor point into consideration
            let gestureLocation = recognizer.location(in: self)
            let newCenter = superview!.convert(gestureLocation, from: self)
            animatableCenter.reset(to: newCenter)

            var anchorPoint = gestureLocation
            anchorPoint.x /= bounds.width
            anchorPoint.y /= bounds.height
            layer.anchorPoint = anchorPoint
            
            animatableTransform.reset(to: animatableTransform.value)
            centerWhenGestureBegan = animatableCenter.value
            transformWhenGestureBegan = animatableTransform.value
            break
        case .changed:
            var t = transformWhenGestureBegan
            t.rotation += recognizer.rotation
            t.scale *= recognizer.scale
            animatableTransform.reset(to: t)
            
            var center = centerWhenGestureBegan
            center.x += recognizer.translationInView(superview).x
            center.y += recognizer.translationInView(superview).y
            animatableCenter.reset(to: center)
            
            break
        case .ended, .cancelled:
            // Reset the anchor point
            let mid = CGPoint(x: bounds.midX, y: bounds.midY)
            let newCenter = superview!.convert(mid, from: self)
            animatableCenter.value = newCenter
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            var velocity = SimpleTransform.zero
            velocity.scale = recognizer.scaleVelocity
            velocity.rotation = recognizer.rotationVelocity
            var config = SpringConfiguration()
            config.threshold = 0.001
            animatableTransform.configuration = config
            animatableTransform.target = SimpleTransform()
            animatableTransform.velocity = velocity
            
            let centerVel = recognizer.translationVelocityInView(superview)
            var centerConfig = SpringConfiguration()
            centerConfig.tension = 40.0
            centerConfig.damping = 5.0
            let c = CGPoint(x: superview!.bounds.midX, y: superview!.bounds.midY)
            animatableCenter.configuration = centerConfig
            animatableCenter.target = c
            animatableCenter.velocity = centerVel
            break
        default:
            break
        }
    }
    
}
