/*

Copyright (c) 2016, Storehouse Media Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/// A vector with 3 components.
public struct Vector3 {
    
    /// Component at index `0`
    public var x: Scalar
    
    /// Component at index `1`
    public var y: Scalar
    
    /// Component at index `2`
    public var z: Scalar
    
    /// Creates a new `Vector3` instance.
    public init(_ x: Scalar, _ y: Scalar, _ z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Vector3: VectorType {
    
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
        return Vector3(0.0, 0.0, 0.0)
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
    public func interpolatedTo(to: Vector3, alpha: Scalar) -> Vector3 {
        var result = self
        result.interpolateTo(to, alpha: alpha)
        return result
    }
    
    /// Interpolate between the given values.
    public mutating func interpolateTo(to: Vector3, alpha: Scalar) {
        x += alpha * (to.x - x)
        y += alpha * (to.y - y)
        z += alpha * (to.z - z)
    }
}

/// Equatable.
public func ==(lhs: Vector3, rhs: Vector3) -> Bool {
    return lhs.x == rhs.x
        && lhs.y == rhs.y
        && lhs.z == rhs.z
}

/// Product.
public func *(lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(lhs.x*rhs.x, lhs.y*rhs.y, lhs.z*rhs.z)
}

/// Product (in place).
public func *=(inout lhs: Vector3, rhs: Vector3) {
    lhs = lhs * rhs
}

/// Quotient
public func /(lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(lhs.x/rhs.x, lhs.y/rhs.y, lhs.z/rhs.z)
}

/// Quotient (in place).
public func /=(inout lhs: Vector3, rhs: Vector3) {
    lhs = lhs / rhs
}

/// Sum.
public func +(lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(lhs.x+rhs.x, lhs.y+rhs.y, lhs.z+rhs.z)
}

/// Sum (in place).
public func +=(inout lhs: Vector3, rhs: Vector3) {
    lhs = lhs + rhs
}

/// Difference.
public func -(lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(lhs.x-rhs.x, lhs.y-rhs.y, lhs.z-rhs.z)
}

/// Difference (in place).
public func -=(inout lhs: Vector3, rhs: Vector3) {
    lhs = lhs - rhs
}

/// Scalar-Vector product.
public func *(lhs: Scalar, rhs: Vector3) -> Vector3 {
    return Vector3(lhs*rhs.x, lhs*rhs.y, lhs*rhs.z)
}