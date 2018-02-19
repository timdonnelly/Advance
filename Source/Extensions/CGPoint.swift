import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGPoint: VectorConvertible {
    
    /// Creates a new instance from a vector.
    public init(vector: Vector2) {
        self.init(
            x: CGFloat(vector.x),
            y: CGFloat(vector.y))
    }
    
    /// Returns the vector representation.
    public var vector: Vector2 {
        return Vector2(
            x: Scalar(x),
            y: Scalar(y))
    }
}
