import UIKit

final class CoverView: UIView {
    
    let logoView: UIImageView
    
    let urlLabel: UILabel
    
    var URLVisibility: CGFloat = 1.0 {
        didSet {
            urlLabel.alpha = URLVisibility
        }
    }
    
    override init(frame: CGRect) {
        logoView = UIImageView(image: UIImage(named: "logo"))
        logoView.tintColor = UIColor.white
        logoView.sizeToFit()
        
        urlLabel = UILabel(frame: CGRect.zero)
        
        var attribs: [NSAttributedString.Key: Any] = [:]
        attribs[.font] = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        attribs[.foregroundColor] = UIColor.white
        
        urlLabel.attributedText = NSAttributedString(string: "github.com/timdonnelly/Advance", attributes: attribs)
        urlLabel.sizeToFit()
        
        super.init(frame: frame)
        
        addSubview(logoView)
        addSubview(urlLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logoView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        urlLabel.center = CGPoint(x: bounds.midX, y: logoView.frame.maxY + 4.0 + urlLabel.bounds.height/2.0)
    }
    
}
