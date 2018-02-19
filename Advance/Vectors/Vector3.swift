/// A vector with 3 components.
public struct Vector3 {
    
    /// Component at index `0`
    public var x: Scalar
    
    /// Component at index `1`
    public var y: Scalar
    
    /// Component at index `2`
    public var z: Scalar
    
    /// Creates a new `Vector3` instance.
    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Vector3: Vector {
    
    /// Creates a vector for which all components are equal to the given scalar.
    public init(scalar: Scalar) {
        x = scalar
        y = scalar
        z = scalar
    }
    
    /// The number of scalar components in this vector type.
    public static var length: Int {
        return 3
    }
    
    /// The empty vector (all scalar components are equal to `0.0`).
    public static var zero: Vector3 {
        return Vector3(x: 0.0, y: 0.0, z: 0.0)
    }
    
    public subscript(index: Int) -> Scalar {
        get {
            precondition(index >= 0)
            precondition(index < 3)
            switch index {
            case 0:
                return x
            case 1:
                return y
            case 2:
                return z
            default:
                fatalError()
            }
        }
        set {
            precondition(index >= 0)
            precondition(index < 3)
            switch index {
            case 0:
                x = newValue
            case 1:
                y = newValue
            case 2:
                z = newValue
            default:
                break
            }
        }
    }
    
    /// Interpolate between the given values.
    public func interpolated(to otherValue: Vector3, alpha: Scalar) -> Vector3 {
        var result = self
        result.interpolate(to: otherValue, alpha: alpha)
        return result
    }
    
    /// Interpolate between the given values.
    public mutating func interpolate(to otherValue: Vector3, alpha: Scalar) {
        x += alpha * (otherValue.x - x)
        y += alpha * (otherValue.y - y)
        z += alpha * (otherValue.z - z)
    }
    
    public func clamped(min: Vector3, max: Vector3) -> Vector3 {
        return Vector3(
            x: x.clamped(min: min.x, max: max.x),
            y: y.clamped(min: min.y, max: max.y),
            z: z.clamped(min: min.z, max: max.z))
    }
    
    /// Equatable.
    public static func ==(lhs: Vector3, rhs: Vector3) -> Bool {
        return lhs.x == rhs.x
            && lhs.y == rhs.y
            && lhs.z == rhs.z
    }
    
    /// Product.
    public static func *(lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x*rhs.x, y: lhs.y*rhs.y, z: lhs.z*rhs.z)
    }
    
    /// Product (in place).
    public static func *=(lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs * rhs
    }
    
    /// Quotient
    public static func /(lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x/rhs.x, y: lhs.y/rhs.y, z: lhs.z/rhs.z)
    }
    
    /// Quotient (in place).
    public static func /=(lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs / rhs
    }
    
    /// Sum.
    public static func +(lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x+rhs.x, y: lhs.y+rhs.y, z: lhs.z+rhs.z)
    }
    
    /// Sum (in place).
    public static func +=(lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs + rhs
    }
    
    /// Difference.
    public static func -(lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x-rhs.x, y: lhs.y-rhs.y, z: lhs.z-rhs.z)
    }
    
    /// Difference (in place).
    public static func -=(lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs - rhs
    }
    
    /// Scalar-Vector product.
    public static func *(lhs: Scalar, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs*rhs.x, y: lhs*rhs.y, z: lhs*rhs.z)
    }
}


