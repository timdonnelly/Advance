/// Conforming types can be operated on as vectors composed of `Double` components.
public protocol Vector: Equatable {
    
    /// Creates a vector for which all components are equal to the given Double.
    init(repeating value: Double)
    
    /// The length of this vector.
    static var scalarCount: Int { get }

    /// Direct component access. If the given `index` is >= `Self.length`, it
    /// is a programmer error.
    subscript(index: Int) -> Double { get set }
    
    /// The empty vector (all Double components are equal to `0.0`).
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
    
    /// Double-Vector product.
    static func *(lhs: Double, rhs: Self) -> Self
}

extension Vector {
    
    /// Returns a vector where each component is clamped by the corresponding
    /// components in `min` and `max`.
    ///
    /// - parameter x: The vector to be clamped.
    /// - parameter min: Each component in the output vector will `>=` the
    ///   corresponding component in this vector.
    /// - parameter max: Each component in the output vector will be `<=` the
    ///   corresponding component in this vector.
    public func clamped(min: Self, max: Self) -> Self {
        var result = self
        for componentIndex in 0..<type(of: self).scalarCount {
            assert(min[componentIndex] <= max[componentIndex])
            if result[componentIndex] < min[componentIndex] {
                result[componentIndex] = min[componentIndex]
            } else if result[componentIndex] > max[componentIndex] {
                result[componentIndex] = max[componentIndex]
            }
        }
        return result
    }
    
    public func interpolated(to otherValue: Self, alpha: Double) -> Self {
        var result = self
        for componentIndex in 0..<type(of: self).scalarCount {
            result[componentIndex] += (alpha * (otherValue[componentIndex] - result[componentIndex]))
        }
        return result
    }
    
}
