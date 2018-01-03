import UIKit
import Advance

final class GestureView: UIView {
    
    let animatableCenter = Animatable(value: CGPoint.zero)
    ;let animatableTransform = Animatable(value: SimpleTransform())
    
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
            animatableCenter.value = center
        }
    }
    
    @objc fileprivate dynamic func manipulate(_ recognizer: DirectManipulationGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            // Take the anchor point into consideration
            let gestureLocation = recognizer.location(in: self)
            let newCenter = superview!.convert(gestureLocation, from: self)
            animatableCenter.value = newCenter
            
            var anchorPoint = gestureLocation
            anchorPoint.x /= bounds.width
            anchorPoint.y /= bounds.height
            layer.anchorPoint = anchorPoint
            
            animatableTransform.cancelAnimation()
            animatableCenter.cancelAnimation()
            centerWhenGestureBegan = animatableCenter.value
            transformWhenGestureBegan = animatableTransform.value
            break
        case .changed:
            var t = transformWhenGestureBegan
            t.rotation += recognizer.rotation
            t.scale *= recognizer.scale
            animatableTransform.value = t
            
            var center = centerWhenGestureBegan
            center.x += recognizer.translationInView(superview).x
            center.y += recognizer.translationInView(superview).y
            animatableCenter.value = center
            
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
            animatableTransform.spring(to: SimpleTransform(), initialVelocity: velocity, configuration: config)
            
            let centerVel = recognizer.translationVelocityInView(superview)
            var centerConfig = SpringConfiguration()
            centerConfig.tension = 40.0
            centerConfig.damping = 5.0
            let c = CGPoint(x: superview!.bounds.midX, y: superview!.bounds.midY)
            animatableCenter.spring(to: c, initialVelocity: centerVel, configuration: centerConfig)
            break
        default:
            break
        }
    }
    
}
