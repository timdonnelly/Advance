/// A vector with 1 component.
public typealias Vector1 = Double

extension Vector1: Vector {
    
    /// Creates a vector for which all components are equal to the given Double.
    public init(repeating value: Double) {
        self = value
    }
    
    /// The empty vector (all Double components are equal to `0.0`).
    public static var zero: Vector1 {
        return Vector1(0.0)
    }
    
    /// The number of Double components in this vector type.
    public static var scalarCount: Int {
        return 1
    }
    
    public subscript(index: Int) -> Double {
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
    public func interpolated(to otherValue: Vector1, alpha: Double) -> Vector1 {
        var result = self
        result.interpolate(to: otherValue, alpha: alpha)
        return result
    }
    
    /// Interpolate between the given values.
    public mutating func interpolate(to otherValue: Vector1, alpha: Double) {
        self += alpha * (otherValue - self)
    }

}
