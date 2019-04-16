#if canImport(UIKit)

import UIKit

extension UIEdgeInsets: VectorConvertible {
    
    public var vector: Vector4 {
        return Vector4(
            x: Double(top),
            y: Double(left),
            z: Double(bottom),
            w: Double(right))
    }
    
    public init(vector: Vector4) {
        self.init(
            top: CGFloat(vector.x),
            left: CGFloat(vector.y),
            bottom: CGFloat(vector.z),
            right: CGFloat(vector.w))
    }
    
}

#endif
