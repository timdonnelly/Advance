/// Conforming types can be converted to and from vector types.
public protocol VectorConvertible: Equatable {
    
    /// The concrete VectorType implementation that can represent the 
    /// conforming type.
    associatedtype VectorType: SIMD where VectorType.Scalar == Double
    
    /// Creates a new instance from a vector.
    init(vector: VectorType)
    
    /// The vector representation of this instance.
    var vector: VectorType { get }
}

extension VectorConvertible {
    
    /// Returns an instance initialized using the zero vector.
    public static var zero: Self {
        return Self(vector: VectorType.zero)
    }
}

extension VectorConvertible {
    
    /// Interpolates between values.
    ///
    /// - parameter to: The value to interpolate to.
    /// - parameter alpha: The amount (between 0.0 and 1.0) to interpolate,
    ///   where `0` returns the receiver, and `1` returns the `to` value.
    /// - Returns: The interpolated result.
    public func interpolated(to otherValue: Self, alpha: Double) -> Self {
        return Self(vector: vector.interpolated(to: otherValue.vector, alpha: alpha))
    }
    
}

public typealias Vector2 = SIMD2<Double>
public typealias Vector3 = SIMD3<Double>
public typealias Vector4 = SIMD4<Double>

extension SIMD where Scalar == Double {
    
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
        for componentIndex in 0..<scalarCount {
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
        for componentIndex in 0..<scalarCount {
            result[componentIndex] += (alpha * (otherValue[componentIndex] - result[componentIndex]))
        }
        return result
    }
    
}
