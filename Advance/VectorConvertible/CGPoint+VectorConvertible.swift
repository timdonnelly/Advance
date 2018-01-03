import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGPoint: VectorConvertible {
    
    /// The underlying vector type.
    public typealias Vector = Vector2
    
    /// Creates a new instance from a vector.
    public init(vector: Vector) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
    
    /// Returns the vector representation.
    public var vector: Vector {
        return Vector(x: Scalar(x), y: Scalar(y))
    }
}
