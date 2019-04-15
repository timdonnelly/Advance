/// Conforming types can be operated on as vectors composed of `Double` components.

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


public typealias Vector2 = SIMD2<Double>
public typealias Vector3 = SIMD3<Double>
public typealias Vector4 = SIMD4<Double>
