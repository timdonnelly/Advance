extension Double: VectorConvertible {
    
    /// The underlying vector type.
    public typealias Vector = Vector2
    
    /// Creates a new instance from a vector.
    public init(vector: Vector) {
        self.init(vector.x)
    }
    
    /// Returns the vector representation.
    public var vector: Vector {
        return Vector2(x: self, y: 0.0)
    }
}
