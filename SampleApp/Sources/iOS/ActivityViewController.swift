import UIKit

class ActivityViewController: DemoViewController {
    
    let activityView = ActivityView()
    
    let slider = UISlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Logo"
        note = "Drag the slider to disassemble."
                
        activityView.flashing = true
        contentView.addSubview(activityView)
        
        contentView.addSubview(slider)
        slider.alpha = 0.0
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        slider.minimumTrackTintColor = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = min(view.bounds.width, view.bounds.height) * 0.6
        activityView.bounds.size = CGSize(width: size, height: size)
        activityView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        let sliderInset = CGFloat(32.0)
        
        var sliderFrame = CGRect.zero
        sliderFrame.size.width = view.bounds.width - sliderInset*2.0
        sliderFrame.size.height = 44.0
        sliderFrame.origin.x = sliderInset
        sliderFrame.origin.y = view.bounds.maxY - sliderInset - 44.0
        slider.frame = sliderFrame
    }
    
    @objc dynamic func sliderChanged() {
        activityView.assembledAmount = CGFloat(slider.value)
        activityView.flashing = activityView.assembledAmount == 1.0
    }
    
    override func didEnterFullScreen() {
        super.didEnterFullScreen()
        slider.alpha = 1.0
    }
    
    override func didLeaveFullScreen() {
        super.didLeaveFullScreen()
        slider.alpha = 0.0
    }

}
