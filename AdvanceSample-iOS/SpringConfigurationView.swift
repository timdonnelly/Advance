import Foundation
import UIKit

protocol SpringConfigurationViewDelegate: class {
    func springConfigurationViewDidChange(_ view: SpringConfigurationView)
}


class SpringConfigurationView: UIView {
    
    weak var delegate: SpringConfigurationViewDelegate? = nil
    
    var tension: CGFloat {
        get { return CGFloat(tensionSlider.slider.value) }
        set { tensionSlider.slider.value = Float(newValue) }
    }
    
    var damping: CGFloat {
        get { return CGFloat(dampingSlider.slider.value) }
        set { dampingSlider.slider.value = Float(newValue) }
    }
    
    fileprivate let tensionSlider = LabeledSliderView()
    fileprivate let dampingSlider = LabeledSliderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tensionSlider)
        addSubview(dampingSlider)
        
        tensionSlider.slider.addTarget(self, action: #selector(changed), for: .valueChanged)
        dampingSlider.slider.addTarget(self, action: #selector(changed), for: .valueChanged)
        
        tensionSlider.slider.minimumValue = 1.0
        tensionSlider.slider.maximumValue = 400.0
        
        dampingSlider.slider.minimumValue = 0.1
        dampingSlider.slider.maximumValue = 80.0
        
        tensionSlider.slider.value = 120.0
        dampingSlider.slider.value = 10.0
        
        tensionSlider.text = "Tension"
        dampingSlider.text = "Damping"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var s = CGSize.zero
        s.width = size.width
        s.height += tensionSlider.sizeThatFits(size).height
        s.height += dampingSlider.sizeThatFits(size).height
        return s
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        var tensionSize = tensionSlider.sizeThatFits(bounds.size)
        tensionSize.width = bounds.width
        tensionSlider.frame = CGRect(origin: CGPoint.zero, size: tensionSize)
        
        var dampingSize = dampingSlider.sizeThatFits(bounds.size)
        dampingSize.width = bounds.width
        dampingSlider.frame = CGRect(x: 0.0, y: tensionSlider.frame.maxY, width: bounds.width, height: dampingSize.height)
    }
    
    @objc fileprivate dynamic func changed() {
        delegate?.springConfigurationViewDidChange(self)
    }
}


private class LabeledSliderView: UIView {
    
    var labelWidth: CGFloat = 90.0 {
        didSet { setNeedsLayout() }
    }
    
    var gutterWidth: CGFloat = 20.0 {
        didSet { setNeedsLayout() }
    }
    
    var sideMargin: CGFloat = 12.0 {
        didSet { setNeedsLayout() }
    }
    
    var text: String {
        get { return label.text ?? "" }
        set { label.text = newValue }
    }
    
    fileprivate let label: UILabel
    fileprivate let slider: UISlider
    
    override init(frame: CGRect) {
        label = UILabel()
        slider = UISlider()
        super.init(frame: frame)
        
        slider.minimumTrackTintColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
        
        label.text = "Untitled"
        label.textColor = UIColor.darkGray
        
        addSubview(label)
        addSubview(slider)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func sizeThatFits(_ size: CGSize) -> CGSize {
        var s = size
        s.height = 44.0
        return s
    }
    
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        
        var labelSize = label.sizeThatFits(bounds.size)
        labelSize.width = min(labelSize.width, labelWidth)
        label.bounds = CGRect(origin: CGPoint.zero, size: labelSize)
        label.center = CGPoint(x: sideMargin + labelSize.width/2.0, y: bounds.midY)
        
        var sliderFrame = CGRect.zero
        sliderFrame.size.height = slider.sizeThatFits(bounds.size).height
        sliderFrame.size.width = bounds.width - (sideMargin * 2.0) - labelWidth - gutterWidth
        sliderFrame.origin.x = sideMargin + labelWidth + gutterWidth
        sliderFrame.origin.y = (bounds.height - sliderFrame.height) / 2.0
        slider.frame = sliderFrame
    }
}
