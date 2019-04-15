/// A vector with 3 components.
public struct Vector3 {
    
    /// Component at index `0`
    public var x: Double
    
    /// Component at index `1`
    public var y: Double
    
    /// Component at index `2`
    public var z: Double
    
    /// Creates a new `Vector3` instance.
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Vector3: Vector {
    
    /// Creates a vector for which all components are equal to the given Double.
    public init(repeating value: Double) {
        x = value
        y = value
        z = value
    }
    
    /// The number of Double components in this vector type.
    public static var scalarCount: Int {
        return 3
    }
    
    /// The empty vector (all Double components are equal to `0.0`).
    public static var zero: Vector3 {
        return Vector3(x: 0.0, y: 0.0, z: 0.0)
    }
    
    public subscript(index: Int) -> Double {
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
    
    /// Double-Vector product.
    public static func *(lhs: Double, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs*rhs.x, y: lhs*rhs.y, z: lhs*rhs.z)
    }
}

