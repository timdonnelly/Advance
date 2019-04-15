/// A vector with 2 components.
public struct Vector2 {
    
    /// Component at index `0`
    public var x: Double
    
    /// Component at index `1`
    public var y: Double
    
    /// Creates a new `Vector2` instance.
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

extension Vector2: Vector {
    
    /// Creates a vector for which all components are equal to the given Double.
    public init(repeating value: Double) {
        x = value
        y = value
    }

    /// The number of Double components in this vector type.
    public static var scalarCount: Int {
        return 2
    }
    
    /// The empty vector (all Double components are equal to `0.0`).
    public static var zero: Vector2 {
        return Vector2(x: 0.0, y: 0.0)
    }
    
    public subscript(index: Int) -> Double {
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
    
    /// Double-Vector product.
    public static func *(lhs: Double, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs*rhs.x, y: lhs*rhs.y)
    }
}


