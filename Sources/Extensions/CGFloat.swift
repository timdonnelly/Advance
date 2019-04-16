#if canImport(CoreGraphics)

import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGFloat: VectorConvertible {
    
    /// Creates a new instance from a vector.
    public init(vector: Vector2) {
        self.init(vector.x)
    }
    
    /// Returns the vector representation.
    public var vector: Vector2 {
        return Vector2(x: Double(self), y: 0.0)
    }
}

#endif
