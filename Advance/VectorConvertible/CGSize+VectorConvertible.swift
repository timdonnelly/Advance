import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGSize: VectorConvertible {
    
    /// The underlying vector type.
    public typealias Vector = Vector2
    
    /// Creates a new instance from a vector.
    public init(vector: Vector) {
        self.init(width: CGFloat(vector.x), height: CGFloat(vector.y))
    }
    
    /// Returns the vector representation.
    public var vector: Vector {
        return Vector(x: Scalar(width), y: Scalar(height))
    }
}
