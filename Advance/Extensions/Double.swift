/// Adds `VectorConvertible` conformance.
extension Double: VectorConvertible {
    
    /// The underlying vector type.
    public typealias Vector = Vector1
    
    /// Creates a new instance from a vector.
    public init(vector: Vector) {
        self.init(vector)
    }
    
    /// Returns the vector representation.
    public var vector: Vector {
        return Vector(self)
    }
}
