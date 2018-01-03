import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGSize: VectorConvertible {
    
    /// Creates a new instance from a vector.
    public init(vector: Vector2) {
        self.init(width: CGFloat(vector.x), height: CGFloat(vector.y))
    }
    
    /// Returns the vector representation.
    public var vector: Vector2 {
        return Vector2(x: Scalar(width), y: Scalar(height))
    }
}
