/// The underlying type of scalar quantities.
public typealias Scalar = Double

/// Conforming types can be operated on as vectors composed of `Scalar` components.
public protocol Vector: Equatable, Interpolatable {
    
    /// Creates a vector for which all components are equal to the given scalar.
    init(scalar: Scalar)
    
    /// The length of this vector.
    static var length: Int { get }

    /// Direct component access. If the given `index` is >= `Self.length`, it
    /// is a programmer error.
    subscript(index: Int) -> Scalar { get set }
    
    /// Returns a vector where each component is clamped by the corresponding
    /// components in `min` and `max`.
    ///
    /// - parameter x: The vector to be clamped.
    /// - parameter min: Each component in the output vector will `>=` the
    ///   corresponding component in this vector.
    /// - parameter max: Each component in the output vector will be `<=` the
    ///   corresponding component in this vector.
    func clamped(min: Self, max: Self) -> Self
    
    
    /// The empty vector (all scalar components are equal to `0.0`).
    static var zero: Self { get }
    
    /// Product.
    static func *(lhs: Self, rhs: Self) -> Self
    
    /// Product (in place).
    static func *=(lhs: inout Self, rhs: Self)
    
    /// Quotient.
    static func /(lhs: Self, rhs: Self) -> Self
    
    /// Quotient (in place).
    static func /=(lhs: inout Self, rhs: Self)
    
    /// Sum.
    static func +(lhs: Self, rhs: Self) -> Self
    
    /// Sum (in place).
    static func +=(lhs: inout Self, rhs: Self)
    
    /// Difference.
    static func -(lhs: Self, rhs: Self) -> Self
    
    /// Difference (in place).
    static func -=(lhs: inout Self, rhs: Self)
    
    /// Scalar-Vector product.
    static func *(lhs: Scalar, rhs: Self) -> Self
}
