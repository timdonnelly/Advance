import Foundation
import simd

/// Conforming types implement functions for basic vector arithmetic.
public protocol VectorMathCapable {
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
