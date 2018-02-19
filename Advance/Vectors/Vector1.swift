/// A vector with 1 component.
public typealias Vector1 = Scalar

extension Vector1: Vector {
    
    /// Creates a vector for which all components are equal to the given scalar.
    public init(scalar: Scalar) {
        self = scalar
    }
    
    /// The empty vector (all scalar components are equal to `0.0`).
    public static var zero: Vector1 {
        return Vector1(0.0)
    }
    
    /// The number of scalar components in this vector type.
    public static var length: Int {
        return 1
    }
    
    public subscript(index: Int) -> Scalar {
        get {
            precondition(index == 0)
            return self
        }
        set {
            precondition(index == 0)
            self = newValue
        }
    }
    
    /// Interpolate between the given values.
    public func interpolated(to otherValue: Vector1, alpha: Scalar) -> Vector1 {
        var result = self
        result.interpolate(to: otherValue, alpha: alpha)
        return result
    }
    
    /// Interpolate between the given values.
    public mutating func interpolate(to otherValue: Vector1, alpha: Scalar) {
        self += alpha * (otherValue - self)
    }
    
    public func clamped(min: Vector1, max: Vector1) -> Vector1 {
        assert(min <= max)
        if self < min { return min }
        if self > max { return max }
        return self
    }
}
