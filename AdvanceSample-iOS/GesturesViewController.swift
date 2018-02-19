import UIKit

final class GesturesViewController: DemoViewController {
    
    let gestureView = GestureView()

    required init() {
        super.init(nibName: nil, bundle: nil)
        title = "Gestures"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        note = "Use two fingers to pick up the square."
        
        contentView.addSubview(gestureView)

        // Do any additional setup after loading the view.
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
        gestureView.animatableCenter.reset(to: CGPoint(x: contentView.bounds.midX, y: contentView.bounds.midY))
        gestureView.animatableTransform.reset(to: SimpleTransform())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
