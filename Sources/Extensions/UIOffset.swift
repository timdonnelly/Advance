#if os(iOS) || os(tvOS)

import UIKit

extension UIOffset: VectorConvertible {
    
    public var vector: Vector2 {
        return Vector2(
            x: Double(horizontal),
            y: Double(vertical))
    }
    
    public init(vector: Vector2) {
        self.init(
            horizontal: CGFloat(vector.x),
            vertical: CGFloat(vector.y))
    }
    
}

#endif
