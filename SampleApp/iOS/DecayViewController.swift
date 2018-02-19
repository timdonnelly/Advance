import UIKit
import Advance


final class DecayViewController: DemoViewController {
    
    private var currentAnimator: Animator<CGPoint>? = nil
    
    let draggableView = UIView()
    
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
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        draggableView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    override func didLeaveFullScreen() {
        super.didLeaveFullScreen()
        currentAnimator?.cancel()
        currentAnimator = draggableView
            .spring(keyPath: \.center, to: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
    }
    
    
    
    @objc private func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            currentAnimator?.cancel()
            currentAnimator = nil
        case .changed:
            let translation = recognizer.translation(in: contentView)
            recognizer.setTranslation(.zero, in: contentView)
            draggableView.center.x += translation.x
            draggableView.center.y += translation.y
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: contentView)
            currentAnimator = draggableView
                .center
                .decayAnimation(initialVelocity: velocity)
                .run()
                .bound(to: draggableView, keyPath: \.center)
        default:
            break
        }
        
        
    }
    
}
