import UIKit

class DemoViewController: UIViewController {
    
    var note: String {
        get { return noteLabel.text ?? "" }
        set {
            noteLabel.text = newValue
            view.setNeedsLayout()
        }
    }
    
    override var title: String? {
        didSet {
            titleLabel.text = title
            view.setNeedsLayout()
        }
    }
    
    let contentView = UIView()
    
    fileprivate let titleLabel = UILabel()
    
    fileprivate let noteLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        contentView.alpha = 0.4
        contentView.layer.allowsGroupOpacity = false
        contentView.isUserInteractionEnabled = false
        contentView.frame = view.bounds
        view.addSubview(contentView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 32.0, weight: UIFont.Weight.medium)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        noteLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
        noteLabel.textColor = UIColor.darkGray
        noteLabel.textAlignment = .center
        noteLabel.numberOfLines = 0
        noteLabel.alpha = 0.0
        view.addSubview(noteLabel)
    }
    
    final var fullScreen = false {
        didSet {
            guard fullScreen != oldValue else { return }
            
            UIView.animate(withDuration: 0.4, animations: {
                if self.fullScreen {
                    self.didEnterFullScreen()
                } else {
                    self.didLeaveFullScreen()
                }
            }) 
        }
    }
    
    func didEnterFullScreen() {
        noteLabel.alpha = 1.0
        contentView.alpha = 1.0
        contentView.isUserInteractionEnabled = true
        titleLabel.alpha = 0.0
    }
    
    func didLeaveFullScreen() {
        noteLabel.alpha = 0.0
        contentView.alpha = 0.5
        contentView.isUserInteractionEnabled = false
        titleLabel.alpha = 1.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.frame = view.bounds
        
        let labelHeight = noteLabel.sizeThatFits(CGSize(width: view.bounds.width-64.0, height: CGFloat.greatestFiniteMagnitude)).height
        var labelFrame = CGRect.zero
        labelFrame.origin.x = 32.0
        labelFrame.origin.y = 32.0
        labelFrame.size.width = view.bounds.width - 64.0
        labelFrame.size.height = labelHeight
        noteLabel.frame = labelFrame
        
        let titleHeight = titleLabel.sizeThatFits(CGSize(width: view.bounds.width-64.0, height: CGFloat.greatestFiniteMagnitude)).height
        var titleFrame = CGRect.zero
        titleFrame.origin.x = 32.0
        titleFrame.origin.y = 32.0
        titleFrame.size.width = view.bounds.width - 64.0
        titleFrame.size.height = titleHeight
        titleLabel.frame = titleFrame
    }
    
}
