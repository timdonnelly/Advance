#if os(iOS) || os(tvOS)

import UIKit

extension UIEdgeInsets: VectorConvertible {
    
    public var vector: Vector4 {
        return Vector4(
            x: Scalar(top),
            y: Scalar(left),
            z: Scalar(bottom),
            w: Scalar(right))
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
