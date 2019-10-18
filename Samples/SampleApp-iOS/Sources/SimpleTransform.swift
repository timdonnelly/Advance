import Foundation
import CoreGraphics
import Advance

struct SimpleTransform {
    var scale: CGFloat = 1.0
    var rotation: CGFloat = 0.0
    
    init() {}
    
    init(scale: CGFloat, rotation: CGFloat) {
        self.scale = scale
        self.rotation = rotation
    }
    
    var affineTransform: CGAffineTransform {
        var t = CGAffineTransform.identity
        t = t.rotated(by: rotation)
        t = t.scaledBy(x: scale, y: scale)
        return t
    }
}

extension SimpleTransform: VectorConvertible {
        
    var vector: AnimatablePair<CGFloat, CGFloat> {
        AnimatablePair(first: scale, second: rotation)
    }
    
    init(vector: AnimatablePair<CGFloat, CGFloat>) {
        scale = vector.first
        rotation = vector.second
    }

}


