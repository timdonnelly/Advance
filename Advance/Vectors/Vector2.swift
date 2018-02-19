/// A vector with 2 components.
public struct Vector2 {
    
    /// Component at index `0`
    public var x: Scalar
    
    /// Component at index `1`
    public var y: Scalar
    
    /// Creates a new `Vector2` instance.
    public init(x: Scalar, y: Scalar) {
        self.x = x
        self.y = y
    }
}

extension Vector2: Vector {
    
    /// Creates a vector for which all components are equal to the given scalar.
    public init(scalar: Scalar) {
        x = scalar
        y = scalar
    }

    /// The number of scalar components in this vector type.
    public static var length: Int {
        return 2
    }
    
    /// The empty vector (all scalar components are equal to `0.0`).
    public static var zero: Vector2 {
        return Vector2(x: 0.0, y: 0.0)
    }
    
    public subscript(index: Int) -> Scalar {
        get {
            precondition(index >= 0)
            precondition(index < 2)
            switch index {
            case 0:
                return x
            case 1:
                return y
            default:
                fatalError()
            }
        }
        set {
            precondition(index >= 0)
            precondition(index < 2)
            switch index {
            case 0:
                x = newValue
            case 1:
                y = newValue
            default:
                break
            }
        }
    }
    
    public func clamped(min: Vector2, max: Vector2) -> Vector2 {
        return Vector2(
            x: x.clamped(min: min.x, max: max.x),
            y: y.clamped(min: min.y, max: max.y))
    }
    
    /// Interpolate between the given values.
    public func interpolated(to otherValue: Vector2, alpha: Scalar) -> Vector2 {
        var result = self
        result.interpolate(to: otherValue, alpha: alpha)
        return result
    }
    
    /// Interpolate between the given values.
    public mutating func interpolate(to otherValue: Vector2, alpha: Scalar) {
        x += alpha * (otherValue.x - x)
        y += alpha * (otherValue.y - y)
    }
    
    /// Equatable.
    public static func ==(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x == rhs.x
            && lhs.y == rhs.y
    }
    
    /// Product.
    public static func *(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x*rhs.x, y: lhs.y*rhs.y)
    }
    
    /// Product (in place).
    public static func *=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs * rhs
    }
    
    /// Quotient.
    public static func /(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x/rhs.x, y: lhs.y/rhs.y)
    }
    
    /// Quotient (in place).
    public static func /=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs / rhs
    }
    
    /// Sum.
    public static func +(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
    }
    
    /// Sum (in place).
    public static func +=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs + rhs
    }
    
    /// Difference.
    public static func -(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x-rhs.x, y: lhs.y-rhs.y)
    }
    
    /// Difference (in place).
    public static func -=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs - rhs
    }
    
    /// Scalar-Vector product.
    public static func *(lhs: Scalar, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs*rhs.x, y: lhs*rhs.y)
    }
}


