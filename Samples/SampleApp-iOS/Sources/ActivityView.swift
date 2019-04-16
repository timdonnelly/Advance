import UIKit
import Advance



public final class ActivityView: UIView {
    
    fileprivate static let points: [CGPoint] = {
        var points: [CGPoint] = Array(repeating: CGPoint.zero, count: 10)
        points[0] = CGPoint(x: 0.5, y: 0.0)
        points[1] = CGPoint(x: 0.20928571428571, y: 0.16642857142857)
        points[2] = CGPoint(x: 0.79071428571429, y: 0.16642857142857)
        points[3] = CGPoint(x: 0.5, y: 0.3325)
        points[4] = CGPoint(x: 0.20928571428571, y: 0.49964285714286)
        points[5] = CGPoint(x: 0.79071428571429, y: 0.49964285714286)
        points[6] = CGPoint(x: 0.5, y: 0.66607142857143)
        points[7] = CGPoint(x: 0.20928571428571, y: 0.83357142857143)
        points[8] = CGPoint(x: 0.79071428571429, y: 0.83357142857143)
        points[9] = CGPoint(x: 0.5, y: 1.0)
        return points
    }()
    
    fileprivate let segments: [ActivitySegment] = {
        var segments: [ActivitySegment] = []
        segments.append(ActivitySegment(firstPoint: points[1], secondPoint: points[0]))
        segments.append(ActivitySegment(firstPoint: points[0], secondPoint: points[2]))
        segments.append(ActivitySegment(firstPoint: points[1], secondPoint: points[3]))
        segments.append(ActivitySegment(firstPoint: points[2], secondPoint: points[3]))
        segments.append(ActivitySegment(firstPoint: points[1], secondPoint: points[4]))
        segments.append(ActivitySegment(firstPoint: points[4], secondPoint: points[3]))
        segments.append(ActivitySegment(firstPoint: points[3], secondPoint: points[5]))
        segments.append(ActivitySegment(firstPoint: points[4], secondPoint: points[6]))
        segments.append(ActivitySegment(firstPoint: points[6], secondPoint: points[5]))
        segments.append(ActivitySegment(firstPoint: points[5], secondPoint: points[8]))
        segments.append(ActivitySegment(firstPoint: points[6], secondPoint: points[7]))
        segments.append(ActivitySegment(firstPoint: points[6], secondPoint: points[8]))
        segments.append(ActivitySegment(firstPoint: points[7], secondPoint: points[9]))
        segments.append(ActivitySegment(firstPoint: points[8], secondPoint: points[9]))
        return segments
    }()
    
    fileprivate let visibilitySprings: [Spring<CGFloat>] = {
        return (0...13).map {_ in
            let s = Spring(value: CGFloat(1.0))
            s.threshold = 0.001
            s.tension = 220.0 + Double(arc4random() % 200);
            s.damping = 30.0 + Double(arc4random() % 10);
            return s
        }
    }()
    
    fileprivate var segmentLayers: [CAShapeLayer] = {
        return (0...13).map {_ in
            let sl = CAShapeLayer()
            var actions: [String: AnyObject] = [:]
            actions["position"] = NSNull()
            actions["bounds"] = NSNull()
            actions["lineWidth"] = NSNull()
            actions["strokeColor"] = NSNull()
            actions["path"] = NSNull()
            return sl
        }
    }()
    
    fileprivate var strokeColor: UIColor {
        return color.withAlphaComponent(0.6)
    }
    
    fileprivate var flashStrokeColor: UIColor {
        return color
    }
    
    fileprivate let lineWidth = CGFloat(1.0)
    fileprivate let flashLineWidth = CGFloat(2.0)
    
    fileprivate var flashTimer: Timer? = nil
    
    public var color = UIColor(red: 0.0, green: 196.0/255.0, blue: 1.0, alpha: 1.0) {
        didSet {
            for sl in segmentLayers {
                sl.strokeColor = strokeColor.cgColor
            }
        }
    }
    
    public var assembledAmount: CGFloat = 1.0 {
        didSet {
            updateSegmentVisibility(true)
        }
    }
    
    public var flashing: Bool = false {
        didSet {
            guard flashing != oldValue else { return }
            if flashing {
                let t = Timer(timeInterval: 1.0, target: self, selector: #selector(flash), userInfo: nil, repeats: true)
                RunLoop.main.add(t, forMode: RunLoop.Mode.common)
                flashTimer = t
                flash()
            } else {
                flashTimer?.invalidate()
                flashTimer = nil
            }
        }
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        layer.allowsGroupOpacity = false
        
        for vs in visibilitySprings {
            vs.onChange = { [weak self] (vis) in
                self?.setNeedsLayout()
            }
        }
        
        for sl in segmentLayers {
            sl.strokeColor = strokeColor.cgColor
            sl.lineWidth = lineWidth
            layer.addSublayer(sl)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        for i in 0..<segments.count {
            let s = segments[i]
            let sl = segmentLayers[i]
            let visibility = visibilitySprings[i].value
            sl.frame = bounds
            sl.path = s.path(bounds.size, visibility: visibility).cgPath
            sl.opacity = Float(visibility)
        }
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 40.0, height: 40.0)
    }
    
    public func resetAssembledAmount(_ assembledAmount: CGFloat) {
        self.assembledAmount = assembledAmount
        updateSegmentVisibility(false)
    }
    
    func updateSegmentVisibility(_ animated: Bool) {
        for i in 0..<segments.count {
            let positionInArray = CGFloat(i) / CGFloat(segments.count-1)
            
            let minVis = (1.0-positionInArray) * 0.4
            let maxVis = minVis + 0.6
            
            var mappedVis = (assembledAmount - minVis) / (maxVis - minVis)
            mappedVis = min(mappedVis, 1.0)
            mappedVis = max(mappedVis, 0.0)
            mappedVis = quadEaseInOut(mappedVis)
            
            if animated {
                visibilitySprings[i].target = mappedVis
            } else {
                visibilitySprings[i].reset(to: mappedVis)
            }
        }
    }

    @objc fileprivate dynamic func flash() {
        for i in 0..<segmentLayers.count {
            let t = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 0.04 * Double(i))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: t, execute: { 
                self.flashSegment(i)
            })
        }
    }
    
    fileprivate func flashSegment(_ index: Int) {
        let sl = segmentLayers[index]
        
        CATransaction.begin()
        
        let c = CAKeyframeAnimation(keyPath: "strokeColor")
        c.values = [strokeColor.cgColor, flashStrokeColor.cgColor, strokeColor.cgColor]
        c.keyTimes = [0.0, 0.3, 1.0]
        c.calculationMode = CAAnimationCalculationMode.cubic
        c.duration = 0.5
        sl.add(c, forKey: "flashStrokeColor")
        
        let s = CAKeyframeAnimation(keyPath: "lineWidth")
        s.values = [lineWidth, flashLineWidth, lineWidth]
        s.keyTimes = [0.0, 0.3, 1.0]
        s.calculationMode = CAAnimationCalculationMode.cubic
        s.duration = 0.5
        sl.add(s, forKey: "flashLineWidth")
        
        CATransaction.commit()
    }
}

private func quadEaseInOut(_ t: CGFloat) -> CGFloat {
    var result = t / 0.5
    if (result < 1.0) {
        return 0.5*result*result
    } else {
        result -= 1.0
        return -0.5 * (result * (result - 2.0) - 1.0)
    }
}


private struct ActivitySegment {
    
    let firstPoint: CGPoint
    let secondPoint: CGPoint
    
    let initialPosition: CGPoint = {
        var p = CGPoint.zero
        p.x = (CGFloat(arc4random() % 100) / 100.0)
        p.y = (CGFloat(arc4random() % 100) / 100.0)
        p.x = ((p.x - 0.5) * 2.0) + 0.5
        p.y -= 0.6;
        return p
    }()
    
    let initialRotation = ((CGFloat(arc4random() % 100) / 100.0) * CGFloat.pi)
    
    func path(_ size: CGSize, visibility: CGFloat) -> UIBezierPath {
        var p1 = initialPosition
        var p2 = initialPosition
        
        p1 = interpolate(from: p1, to: firstPoint, alpha: visibility)
        p2 = interpolate(from: p2, to: secondPoint, alpha: visibility)
        
        let rotation = initialRotation * (1.0 - visibility)
        let midX = p1.x + (p2.x - p1.x) * 0.5
        let midY = p1.y + (p2.y - p1.y) * 0.5
        
        p1.x -= midX
        p2.x -= midX
        p1.y -= midY
        p2.y -= midY
        
        p1 = p1.applying(CGAffineTransform(rotationAngle: rotation))
        p2 = p2.applying(CGAffineTransform(rotationAngle: rotation))
        
        p1.x += midX
        p2.x += midX
        p1.y += midY
        p2.y += midY
        
        // we store layout info in relative coords
        p1.x *= size.width
        p1.y *= size.height
        p2.x *= size.width
        p2.y *= size.height
        
        let p = UIBezierPath()
        p.move(to: p1)
        p.addLine(to: p2)
        
        return p
    }
    
    init(firstPoint: CGPoint, secondPoint: CGPoint) {
        self.firstPoint = firstPoint
        self.secondPoint = secondPoint
    }
}

fileprivate func interpolate(from fromPoint: CGPoint, to toPoint: CGPoint, alpha: CGFloat) -> CGPoint {
    return CGPoint(
        x: fromPoint.x + ((toPoint.x - fromPoint.x) * alpha),
        y: fromPoint.y + ((toPoint.y - fromPoint.y) * alpha))
}
