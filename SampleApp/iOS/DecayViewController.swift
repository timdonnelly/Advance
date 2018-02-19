import UIKit
import Advance


final class DecayViewController: DemoViewController {
        
    let draggableView: UIView
    
    let centerAnimator: PropertyAnimator<UIView, CGPoint>
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        draggableView = UIView()
        centerAnimator = PropertyAnimator(target: draggableView, keyPath: \.center)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Decay"
        note = "Drag the box."
        
        draggableView.bounds.size = CGSize(width: 64.0, height: 64.0)
        draggableView.backgroundColor = UIColor.lightGray
        draggableView.layer.cornerRadius = 8.0
        contentView.addSubview(draggableView)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        draggableView.addGestureRecognizer(gestureRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tapRecognizer)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        draggableView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    override func didLeaveFullScreen() {
        super.didLeaveFullScreen()
        centerAnimator.spring(to: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
    }
    
    
    
    @objc private func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            centerAnimator.cancelRunningAnimation()
        case .changed:
            let translation = recognizer.translation(in: contentView)
            recognizer.setTranslation(.zero, in: contentView)
            centerAnimator.value.x += translation.x
            centerAnimator.value.y += translation.y
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: contentView)
            centerAnimator.decay(initialVelocity: velocity)
        default:
            break
        }
        
    }
    
    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: contentView)
        guard !draggableView.frame.contains(tapLocation) else { return }
        centerAnimator.spring(to: tapLocation)
    }
    
}
