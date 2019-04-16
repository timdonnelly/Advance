import UIKit
import Advance

final class GesturesViewController: DemoViewController {
    
    private let gestureView = UIView()
    
    private let centerSpring = Spring(value: CGPoint.zero)
    private let transformSpring = Spring(value: SimpleTransform())
    
    private let recognizer = DirectManipulationGestureRecognizer()
    
    private var centerWhenGestureBegan = CGPoint.zero
    private var transformWhenGestureBegan = SimpleTransform.zero

    required init() {
        super.init(nibName: nil, bundle: nil)
        title = "Gestures"
        
        recognizer.addTarget(self, action: #selector(gesture))
        gestureView.addGestureRecognizer(recognizer)
        
        centerSpring.threshold = 0.1
        centerSpring.tension = 40
        centerSpring.damping = 5
        centerSpring.onChange = { [weak self] point in self?.gestureView.center = point }
        
        transformSpring.threshold = 0.001
        transformSpring.onChange = { [weak self] (transform) in
            self?.gestureView.transform = transform.affineTransform
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        note = "Use two fingers to pick up the square."
        
        gestureView.backgroundColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
        contentView.addSubview(gestureView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var b = CGRect.zero
        b.size.width = min(view.bounds.width, view.bounds.height) - 64.0
        b.size.height = b.size.width
        gestureView.bounds = b
        centerSpring.reset(to: CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY))
        transformSpring.reset(to: SimpleTransform())
    }
    
    @objc private func gesture(recognizer: DirectManipulationGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            // Take the anchor point into consideration
            let gestureLocation = recognizer.location(in: gestureView)
            let newCenter = contentView.convert(gestureLocation, from: gestureView)
            centerSpring.reset(to: newCenter)
            
            var anchorPoint = gestureLocation
            anchorPoint.x /= gestureView.bounds.width
            anchorPoint.y /= gestureView.bounds.height
            gestureView.layer.anchorPoint = anchorPoint
            
            transformSpring.reset(to: transformSpring.value)
            centerWhenGestureBegan = centerSpring.value
            transformWhenGestureBegan = transformSpring.value
            break
        case .changed:
            var t = transformWhenGestureBegan
            t.rotation += recognizer.rotation
            t.scale *= recognizer.scale
            transformSpring.reset(to: t)
            
            var center = centerWhenGestureBegan
            center.x += recognizer.translationInView(contentView).x
            center.y += recognizer.translationInView(contentView).y
            centerSpring.reset(to: center)
            
            break
        case .ended, .cancelled:
            // Reset the anchor point
            let mid = CGPoint(x: gestureView.bounds.midX, y: gestureView.bounds.midY)
            let newCenter = contentView.convert(mid, from: gestureView)
            centerSpring.value = newCenter
            gestureView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            var velocity = SimpleTransform.zero
            velocity.scale = recognizer.scaleVelocity
            velocity.rotation = recognizer.rotationVelocity
            transformSpring.target = SimpleTransform()
            transformSpring.velocity = velocity
            
            centerSpring.target = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY)
            centerSpring.velocity = recognizer.translationVelocityInView(contentView)
            break
        default:
            break
        }
    }

}
