import UIKit
import Advance

class GravityViewController: DemoViewController {
    
    var simulation = GravitySimulation() {
        didSet {
            loop.paused = simulation.settled
            view.setNeedsLayout()
        }
    }
    
    private let loop = Loop()
    
    let resetButton = UIButton()
    
    fileprivate var nodeLayers: [[CALayer]] = []
    
    fileprivate var lastLayoutSize: CGSize = CGSize.zero
    
    fileprivate let recognizer = UILongPressGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loop.frames.observe { [weak self] frame in
            guard let strongSelf = self else { return }
            strongSelf.simulation.advance(by: frame.duration)
            if strongSelf.simulation.settled {
                strongSelf.loop.paused = true
            }
        }
        
        title = "Gravity"
        note = "Long press to add gravity."
        
        recognizer.minimumPressDuration = 0.3
        recognizer.addTarget(self, action: #selector(press(_:)))
        recognizer.isEnabled = false
        contentView.addGestureRecognizer(recognizer)
        
        resetButton.setTitle("Reset", for: UIControlState())
        resetButton.setTitleColor(UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0), for: UIControlState())
        resetButton.layer.cornerRadius = 4.0
        resetButton.tintColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
        resetButton.layer.borderColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        resetButton.layer.borderWidth = 1.0
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        resetButton.alpha = 0.0
        view.addSubview(resetButton)
        
        
        for r in 0..<simulation.rows {
            nodeLayers.append([])
            for _ in 0..<simulation.cols {
                let layer = CALayer()
                layer.backgroundColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0).cgColor
                layer.bounds = CGRect(x: 0.0, y: 0.0, width: 8.0, height: 8.0)
                layer.cornerRadius = 4.0
                layer.actions = ["position": NSNull()]
                nodeLayers[r].append(layer)
                contentView.layer.addSublayer(layer)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.bounds.size != lastLayoutSize {
            lastLayoutSize = view.bounds.size
            reset()
        }
        
        for r in 0..<simulation.rows {
            for c in 0..<simulation.cols {
                let position = simulation.getPosition(row: r, col: c)
                nodeLayers[r][c].position = position
            }
        }
        
        resetButton.bounds = CGRect(x: 0.0, y: 0.0, width: 120.0, height: 44.0)
        resetButton.center = CGPoint(x: contentView.bounds.midX, y: contentView.bounds.maxY - 64.0)
    }
    
    @objc dynamic func press(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            simulation.target = recognizer.location(in: view)
        case .ended:
            simulation.target = nil
        default:
            break
        }
    }
    
    @objc dynamic func reset() {
        simulation.reset(layoutBounds: view.bounds.insetBy(dx: 64.0, dy: 128.0))
    }
    
    override func didEnterFullScreen() {
        super.didEnterFullScreen()
        recognizer.isEnabled = true
        resetButton.alpha = 1.0
    }
    
    override func didLeaveFullScreen() {
        super.didLeaveFullScreen()
        recognizer.isEnabled = false
        resetButton.alpha = 0.0
    }
}
