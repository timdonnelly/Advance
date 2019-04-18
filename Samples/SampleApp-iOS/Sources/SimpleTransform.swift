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
    typealias Vector = Vector2
    
    var vector: Vector {
        return Vector2(x: Double(scale), y: Double(rotation))
    }
    
    init(vector: Vector) {
        scale = CGFloat(vector.x)
        rotation = CGFloat(vector.y)
    }

}


