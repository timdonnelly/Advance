import CoreGraphics

/// Adds `VectorConvertible` conformance.
extension CGFloat: VectorConvertible {
    
    /// Creates a new instance from a vector.
    public init(vector: Vector1) {
        self.init(vector)
    }
    
    /// Returns the vector representation.
    public var vector: Vector1 {
        return Vector1(self)
    }
}
