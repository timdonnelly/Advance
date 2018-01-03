import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGVector: VectorConvertible {
    
    /// The underlying vector type.
    public typealias Vector = Vector2
    
    /// Creates a new instance from a vector.
    public init(vector: Vector) {
        self.init(dx: CGFloat(vector.x), dy: CGFloat(vector.y))
    }
    
    /// Returns the vector representation.
    public var vector: Vector {
        return Vector(x: Scalar(dx), y: Scalar(dy))
    }
}
