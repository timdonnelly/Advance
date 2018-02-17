/// Conforming types can be converted to and from vector types.
public protocol VectorConvertible: Equatable, Interpolatable {
    
    /// The concrete VectorType implementation that can represent the 
    /// conforming type.
    associatedtype VectorType: Vector
    
    /// Creates a new instance from a vector.
    init(vector: VectorType)
    
    /// The vector representation of this instance.
    var vector: VectorType { get }
}

public extension VectorConvertible {
    
    /// Returns an instance initialized using the zero vector.
    public static var zero: Self {
        return Self(vector: VectorType.zero)
    }
}

public extension VectorConvertible {
    
    /// Interpolates between values.
    ///
    /// - parameter to: The value to interpolate to.
    /// - parameter alpha: The amount (between 0.0 and 1.0) to interpolate,
    ///   where `0` returns the receiver, and `1` returns the `to` value.
    /// - Returns: The interpolated result.
    public func interpolated(to otherValue: Self, alpha: Scalar) -> Self {
        return Self(vector: vector.interpolated(to: otherValue.vector, alpha: alpha))
    }
    
}

public extension VectorConvertible {
    
    init(scalar: Scalar) {
        self.init(vector: VectorType(scalar: scalar))
    }
    
    func clamped(min: Self, max: Self) -> Self {
        return Self.init(vector: vector.clamped(min: min.vector, max: max.vector))
    }
    
    /// Product.
    static func *(lhs: Self, rhs: Self) -> Self {
        return Self.init(vector: lhs.vector * rhs.vector)
    }
    
    /// Product (in place).
    static func *=(lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
    /// Quotient.
    static func /(lhs: Self, rhs: Self) -> Self {
        return Self.init(vector: lhs.vector / rhs.vector)
    }
    
    /// Quotient (in place).
    static func /=(lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
    
    /// Sum.
    static func +(lhs: Self, rhs: Self) -> Self {
        return Self.init(vector: lhs.vector + rhs.vector)
    }
    
    /// Sum (in place).
    static func +=(lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    /// Difference.
    static func -(lhs: Self, rhs: Self) -> Self {
        return Self.init(vector: lhs.vector - rhs.vector)
    }
    
    /// Difference (in place).
    static func -=(lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    /// Scalar-Vector product.
    static func *(lhs: Scalar, rhs: Self) -> Self {
        return Self.init(vector: lhs * rhs.vector)
    }
    
}
