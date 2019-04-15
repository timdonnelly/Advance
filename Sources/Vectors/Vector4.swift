/// A vector with 4 component.
public struct Vector4 {
    
    /// Component at index `0`
    public var x: Double
    
    /// Component at index `1`
    public var y: Double
    
    /// Component at index `2`
    public var z: Double
    
    /// Component at index `3`
    public var w: Double
    
    /// Creates a new `Vector4` instance.
    public init(x: Double, y: Double, z: Double, w: Double) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}

extension Vector4: Vector {
    
    /// Creates a vector for which all components are equal to the given Double.
    public init(repeating value: Double) {
        x = value
        y = value
        z = value
        w = value
    }
    
    /// The number of Double components in this vector type.
    public static var scalarCount: Int {
        return 4
    }
    
    /// The empty vector (all Double components are equal to `0.0`).
    public static var zero: Vector4 {
        return Vector4(x: 0.0, y: 0.0, z: 0.0, w: 0.0)
    }
    
    public subscript(index: Int) -> Double {
        get {
            precondition(index >= 0)
            precondition(index < 4)
            switch index {
            case 0:
                return x
            case 1:
                return y
            case 2:
                return z
            case 3:
                return w
            default:
                fatalError()
            }
        }
        set {
            precondition(index >= 0)
            precondition(index < 4)
            switch index {
            case 0:
                x = newValue
            case 1:
                y = newValue
            case 2:
                z = newValue
            case 3:
                w = newValue
            default:
                break
            }
        }
    }
    
    /// Interpolate between the given values.
    public func interpolated(to otherValue: Vector4, alpha: Double) -> Vector4 {
        var result = self
        result.interpolate(to: otherValue, alpha: alpha)
        return result
    }
    
    /// Interpolate between the given values.
    public mutating func interpolate(to otherValue: Vector4, alpha: Double) {
        x += alpha * (otherValue.x - x)
        y += alpha * (otherValue.y - y)
        z += alpha * (otherValue.z - z)
        w += alpha * (otherValue.w - w)
    }
    
    /// Equatable.
    public static func ==(lhs: Vector4, rhs: Vector4) -> Bool {
        return lhs.x == rhs.x
            && lhs.y == rhs.y
            && lhs.z == rhs.z
            && lhs.w == rhs.w
    }
    
    /// Product.
    public static func *(lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x*rhs.x, y: lhs.y*rhs.y, z: lhs.z*rhs.z, w: lhs.w*rhs.w)
    }
    
    /// Product (in place).
    public static func *=(lhs: inout Vector4, rhs: Vector4) {
        lhs = lhs * rhs
    }
    
    /// Quotient
    public static func /(lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x/rhs.x, y: lhs.y/rhs.y, z: lhs.z/rhs.z, w: lhs.w/rhs.w)
    }
    
    /// Quotient (in place).
    public static func /=(lhs: inout Vector4, rhs: Vector4) {
        lhs = lhs / rhs
    }
    
    /// Sum.
    public static func +(lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x+rhs.x, y: lhs.y+rhs.y, z: lhs.z+rhs.z, w: lhs.w+rhs.w)
    }
    
    /// Sum (in place).
    public static func +=(lhs: inout Vector4, rhs: Vector4) {
        lhs = lhs + rhs
    }
    
    /// Difference.
    public static func -(lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x-rhs.x, y: lhs.y-rhs.y, z: lhs.z-rhs.z, w: lhs.w-rhs.w)
    }
    
    /// Difference (in place).
    public static func -=(lhs: inout Vector4, rhs: Vector4) {
        lhs = lhs - rhs
    }
    
    /// Double-Vector product.
    public static func *(lhs: Double, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs*rhs.x, y: lhs*rhs.y, z: lhs*rhs.z, w: lhs*rhs.w)
    }
}


