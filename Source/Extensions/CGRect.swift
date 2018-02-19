import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGRect: VectorConvertible {
    
    /// Creates a new instance from a vector.
    public init(vector: Vector4) {
        self.init(
            x: CGFloat(vector.x),
            y: CGFloat(vector.y),
            width: CGFloat(vector.z),
            height: CGFloat(vector.w))
    }
    
    /// Returns the vector representation.
    public var vector: Vector4 {
        return Vector4(
            x: Scalar(origin.x),
            y: Scalar(origin.y),
            z: Scalar(size.width),
            w: Scalar(size.height))
    }
}
