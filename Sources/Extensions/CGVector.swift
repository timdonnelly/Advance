import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGVector: VectorConvertible {
    
    /// Creates a new instance from a vector.
    public init(vector: Vector2) {
        self.init(dx: CGFloat(vector.x), dy: CGFloat(vector.y))
    }
    
    /// Returns the vector representation.
    public var vector: Vector2 {
        return Vector2(x: Scalar(dx), y: Scalar(dy))
    }
}
