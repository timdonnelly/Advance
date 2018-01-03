import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGRect: VectorConvertible {
    
    /// The underlying vector type.
    public typealias Vector = Vector4
    
    /// Creates a new instance from a vector.
    public init(vector: Vector) {
        origin = CGPoint(x: CGFloat(vector.x), y: CGFloat(vector.y))
        size = CGSize(width: CGFloat(vector.z), height: CGFloat(vector.w))
    }
    
    /// Returns the vector representation.
    public var vector: Vector {
        return Vector(x: Scalar(origin.x), y: Scalar(origin.y), z: Scalar(size.width), w: Scalar(size.height))
    }
}
