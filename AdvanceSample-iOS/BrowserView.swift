/*

Copyright (c) 2016, Storehouse Media Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

import UIKit
import Advance

class BrowserItem: NSObject {
    
    let center = Spring(value: CGPoint.zero)
    let transform = Spring(value: SimpleTransform())
    let size = Spring(value: CGSize.zero)
    
    let tapRecognizer = UITapGestureRecognizer()

    let recognizer = DirectManipulationGestureRecognizer()
    let panRecognizer = UIPanGestureRecognizer()
    
    var anchorPoint = CGPoint(x: 0.5, y: 0.5) {
        didSet { browserView?.setNeedsLayout() }
    }
    
    let view: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = UIColor.blue
        v.layer.cornerRadius = 6.0
        v.clipsToBounds = true
        return v
    }()
    
    fileprivate var transformWhenGestureBegan = SimpleTransform()
    fileprivate var centerWhenGestureBegan = CGPoint.zero
    fileprivate (set) var gestureInProgress = false
    
    var frame: CGRect {
        var f = CGRect.zero
        f.size = size.value
        f.origin.x -= anchorPoint.x * f.size.width
        f.origin.y -= anchorPoint.y * f.size.height
        f = f.applying(transform.value.affineTransform)
        f.origin.x += center.value.x
        f.origin.y += center.value.y
        return f
    }
    
    fileprivate (set) weak var browserView: BrowserView? = nil
    
    override init() {
        super.init()
        
        center.configuration.threshold = 0.1
        center.configuration.tension = 120.0
        center.configuration.damping = 27.0
        center.changed.observe { [unowned self] (p) -> Void in
            self.browserView?.setNeedsLayout()
        }
        
        transform.configuration.threshold = 0.001
        transform.changed.observe { [unowned self] (p) -> Void in
            self.browserView?.setNeedsLayout()
        }
        
        size.configuration.threshold = 0.1
        size.changed.observe { [unowned self] (p) -> Void in
            self.browserView?.setNeedsLayout()
        }
        
        tapRecognizer.addTarget(self, action: #selector(tap))
        view.addGestureRecognizer(tapRecognizer)
        
        recognizer.addTarget(self, action: #selector(gesture(_:)))
        view.addGestureRecognizer(recognizer)
        
        panRecognizer.addTarget(self, action: #selector(pan(_:)))
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
    }
    
    @objc fileprivate dynamic func tap() {
        if browserView?.fullScreenItem != self {
            browserView?.enterFullScreen(self)
        }
    }
    
    @objc fileprivate dynamic func gesture(_ recognizer: DirectManipulationGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            let gestureLocation = recognizer.location(in: view)
            let newCenter = view.superview!.convert(gestureLocation, from: view)
            center.reset(to: newCenter)
            
            var anchorPoint = gestureLocation
            anchorPoint.x /= view.bounds.width
            anchorPoint.y /= view.bounds.height
            self.anchorPoint = anchorPoint
            
            gestureInProgress = true
            centerWhenGestureBegan = center.value
            transformWhenGestureBegan = transform.value
            transform.reset(to: transform.value)
        case .changed:
            var t = transformWhenGestureBegan
            t.rotation += recognizer.rotation
            t.scale *= recognizer.scale
            transform.reset(to: t)
            
            var c = centerWhenGestureBegan
            c.x += recognizer.translationInView(view.superview).x
            c.y += recognizer.translationInView(view.superview).y
            center.reset(to: c)
            break
        case .ended, .cancelled:
            
            // Reset the anchor point
            let mid = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            let newCenter = view.superview!.convert(mid, from: view)
            center.reset(to: newCenter)
            anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            var velocity = SimpleTransform.zero
            velocity.scale = recognizer.scaleVelocity
            velocity.rotation = recognizer.rotationVelocity
            var config = SpringConfiguration()
            config.threshold = 0.001
            transform.velocity = velocity
            
            let centerVel = recognizer.translationVelocityInView(view.superview)
            var centerConfig = SpringConfiguration()
            centerConfig.tension = 40.0
            centerConfig.damping = 5.0
            center.velocity = centerVel
            
            gestureInProgress = false
            
            if recognizer.scaleVelocity <= 0.0 && transform.value.scale < 1.0 && browserView?.fullScreenItem == self {
                browserView?.leaveFullScreen()
            } else if recognizer.scaleVelocity >= 0.0 && transform.value.scale > 0.75 && browserView?.fullScreenItem != self {
                browserView?.enterFullScreen(self)
            } else {
                browserView?.updateAllItems(true)
            }
            break
        default:
            break
        }
    }
    
    @objc dynamic func pan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            gestureInProgress = true
            centerWhenGestureBegan = center.value
            center.reset(to: center.value)
            break
        case .changed:
            var c = centerWhenGestureBegan
            c.y += recognizer.translation(in: view.superview).y
            center.reset(to: c)
            break
        case .ended:
            gestureInProgress = false
            center.velocity.y = recognizer.velocity(in: view.superview).y
            if abs(recognizer.translation(in: view.superview).y) > 10.0 {
                browserView?.leaveFullScreen()
            } else {
                browserView?.updateAllItems(true)
            }
        default:
            break
        }
    }
}

extension BrowserItem: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer {
            if browserView?.fullScreenItem != self {
                return false
            }
            
            let translation = panRecognizer.translation(in: view)
            if abs(translation.x) > abs(translation.y) {
                return false
            }
        }
        return true
    }
}

func ==(lhs: BrowserItem, rhs: BrowserItem) -> Bool {
    return lhs === rhs
}

protocol BrowserViewDelegate: class {
    func browserView(_ browserView: BrowserView, didShowItem item: BrowserItem)
    func browserView(_ browserView: BrowserView, didHideItem item: BrowserItem)
    func browserView(_ browserView: BrowserView, didEnterFullScreenForItem item: BrowserItem)
    func browserView(_ browserView: BrowserView, didLeaveFullScreenForItem item: BrowserItem)
    func browserViewDidScroll(_ browserView: BrowserView)
}

class BrowserView: UIView {
    
    weak var delegate: BrowserViewDelegate? = nil
    
    fileprivate let paginationRatio: CGFloat = 0.68
    
    fileprivate let index = Animatable(value: CGFloat.zero)
    
    fileprivate var panInProgress = false
    fileprivate var indexWhenPanBegan: CGFloat = 0.0
    
    fileprivate var visibleItems: Set<BrowserItem> = []
    
    fileprivate let panRecognizer = UIPanGestureRecognizer()
    
    fileprivate var lastLayoutSize = CGSize.zero
    
    fileprivate var fullScreenItem: BrowserItem? = nil
    
    fileprivate let coverVisibilty: Spring<CGFloat> = {
        let s = Spring(value: CGFloat(1.0))
        s.configuration.threshold = 0.001
        s.configuration.tension = 220.0
        s.configuration.damping = 28.0
        return s
    }()
    
    var coverView: CoverView? = nil {
        didSet {
            guard coverView !== oldValue else { return }
            oldValue?.removeFromSuperview()
            if let v = coverView {
                addSubview(v)
            }
            setNeedsLayout()
        }
    }
    
    
    var currentIndex: CGFloat {
        return index.value
    }
    
    var items: [BrowserItem] = [] {
        willSet {
            leaveFullScreen()
            for item in visibleItems {
                hideItem(item)
            }
            
            for item in items {
                item.browserView = nil
            }
        }
        didSet {
            for item in items {
                item.browserView = self
            }
            updateAllItems(false)
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        index.changed.observe { [unowned self] (idx) -> Void in
            self.setNeedsLayout()
            self.delegate?.browserViewDidScroll(self)
        }
        
        coverVisibilty.changed.observe { [unowned self] (v) in
            self.setNeedsLayout()
        }
        
        panRecognizer.addTarget(self, action: #selector(pan(_:)))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != CGSize.zero else { return }
        
        if lastLayoutSize != bounds.size {
            lastLayoutSize = bounds.size
            updateAllItems(false)
        }
        
        var b = bounds
        b.origin.x = 0.0 + (index.value * b.width * paginationRatio)
        if bounds != b {
            bounds = b
        }
        
        // bring centermost item to front
        var closestDistance = CGFloat.greatestFiniteMagnitude
        var closestItem: BrowserItem? = nil
        for item in visibleItems {
            let distance = abs(item.center.value.x - bounds.midX)
            if distance < closestDistance {
                closestDistance = distance
                closestItem = item
            }
        }
        if let item = closestItem {
            bringSubview(toFront: item.view)
        }
        
        updateAllItems(true)
        updateVisibleItems()
        
        
        // If present, update the cover view.
        if let cv = coverView {
            let cvVis = coverVisibilty.value
            
            let initialCenter = CGPoint(x: bounds.midX, y: bounds.midY)
            let finalCenter = CGPoint(x: bounds.midX, y: bounds.height * 0.3 * 0.25)
            cv.center = initialCenter.interpolated(to: finalCenter, alpha: 1.0-Scalar(cvVis))
            
            let t = CGAffineTransform(scaleX: 0.7 + cvVis*0.3, y: 0.7 + cvVis*0.3)
            cv.transform = t
            
            cv.URLVisibility = CGFloat(cvVis)
            cv.alpha = 0.5 + CGFloat(cvVis*0.5)
        }
        
        var coverVisibility = 1.0 - currentIndex
        coverVisibility = min(coverVisibility, 1.0)
        coverVisibility = max(coverVisibility, 0.0)
        coverVisibilty.target = coverVisibility
    }
    
    fileprivate func updateAllItems(_ animated: Bool) {
        for i in 0..<items.count {
            updateItemAtIndex(i, animated: animated)
        }
    }
    
    fileprivate func updateItemAtIndex(_ index: Int, animated: Bool) {
        let item = items[index]
        guard item.gestureInProgress == false else { return }
        
        var center = CGPoint.zero
        center.y = bounds.midY
        center.x = bounds.width/2.0 + (CGFloat(index+1) * bounds.width * paginationRatio)
        let size = bounds.size
        
        var transform = SimpleTransform()
        
        var distance = abs(center.x - bounds.midX)
        distance = min(distance, bounds.width*paginationRatio) / bounds.width*paginationRatio
        transform.scale = 0.7 - (0.3 * distance)
        
        let tension = 60.0 + Scalar(distance) * 40.0
        
        item.transform.configuration.tension = tension
        item.transform.configuration.damping = 18.0
        
        if item == fullScreenItem {
            transform.scale = 1.0
            item.transform.configuration.tension = 160.0
            item.transform.configuration.damping = 28.0
        }
        
        if animated {
            item.center.target = center
            item.size.target = size
            item.transform.target = transform
        } else {
            item.center.reset(to: center)
            item.size.reset(to: size)
            item.transform.reset(to: transform)
        }
    }

    fileprivate func updateVisibleItems() {
        
        for item in items {
            let isVisible = visibleItems.contains(item)
            let shouldBeVisible = item.frame.intersects(bounds)
            if isVisible && !shouldBeVisible {
                hideItem(item)
            } else if !isVisible && shouldBeVisible {
                showItem(item)
            }
            
            if shouldBeVisible {
                updateViewForItemAtIndex(items.index(of: item)!)
            }
        }
        
    }
    
    fileprivate func showItem(_ item: BrowserItem) {
        assert(item.browserView == self)
        assert(visibleItems.contains(item) == false)
        visibleItems.insert(item)
        updateViewForItemAtIndex(items.index(of: item)!)
        addSubview(item.view)
        delegate?.browserView(self, didShowItem: item)
    }

    fileprivate func updateViewForItemAtIndex(_ index: Int) {
        let item = items[index]
        item.view.bounds = CGRect(origin: CGPoint.zero, size: item.size.value)
        item.view.center = item.center.value
        item.view.layer.anchorPoint = item.anchorPoint
        item.view.transform = item.transform.value.affineTransform
    }
    
    fileprivate func hideItem(_ item: BrowserItem) {
        assert(item.browserView == self)
        assert(visibleItems.contains(item))
        visibleItems.remove(item)
        item.view.removeFromSuperview()
        delegate?.browserView(self, didHideItem: item)
    }
    
    func enterFullScreen(_ item: BrowserItem) {
        assert(item.browserView == self)
        leaveFullScreen()
        fullScreenItem = item
        updateAllItems(true)
        index.animate(to: CGFloat(items.index(of: item)! + 1))
        delegate?.browserView(self, didEnterFullScreenForItem: item)
    }
    
    func leaveFullScreen() {
        guard let item = fullScreenItem else { return }
        fullScreenItem = nil
        updateAllItems(true)
        delegate?.browserView(self, didLeaveFullScreenForItem: item)
    }
    
    @objc fileprivate dynamic func pan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            panInProgress = true
            indexWhenPanBegan = index.value
            index.cancelAnimation()
        case .changed:
            index.value = indexWhenPanBegan - (recognizer.translation(in: self).x / bounds.width * paginationRatio)
            break
        case .ended, .cancelled:
            panInProgress = false
            let vel = -recognizer.velocity(in: self).x / bounds.width * paginationRatio
            var destIndex = round(index.value + (vel/5.0))
            if destIndex == round(index.value) {
                if vel < 0.0 {
                    destIndex -= 1.0
                } else if vel > 0.0 {
                    destIndex += 1.0
                }
            }
            destIndex = min(destIndex, CGFloat(items.count))
            destIndex = max(destIndex, CGFloat(0.0))
            var config = SpringConfiguration()
            config.tension = 120.0
            config.damping = 20.0
            config.threshold = 0.001
            index.spring(to: destIndex, initialVelocity: vel, configuration: config, completion: nil)
        default:
            break
        }
    }
    
}

extension BrowserView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panRecognizer && fullScreenItem != nil {
            return false
        }
        return true
    }
}
