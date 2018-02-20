#if os(iOS) || os(tvOS)

import UIKit

extension UIOffset: VectorConvertible {
    
    public var vector: Vector2 {
        return Vector2(
            x: Scalar(horizontal),
            y: Scalar(vertical))
    }
    
    public init(vector: Vector2) {
        self.init(
            horizontal: CGFloat(vector.x),
            vertical: CGFloat(vector.y))
    }
    
}

#endif
