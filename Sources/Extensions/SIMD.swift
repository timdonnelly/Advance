extension SIMD where Scalar == Double {
    
    /// Returns a vector where each component is clamped by the corresponding
    /// components in `min` and `max`.
    ///
    /// - parameter x: The vector to be clamped.
    /// - parameter min: Each component in the output vector will `>=` the
    ///   corresponding component in this vector.
    /// - parameter max: Each component in the output vector will be `<=` the
    ///   corresponding component in this vector.
    func clamped(min: Self, max: Self) -> Self {
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
    
    func interpolated(to otherValue: Self, alpha: Double) -> Self {
        var result = self
        for componentIndex in 0..<scalarCount {
            result[componentIndex] += (alpha * (otherValue[componentIndex] - result[componentIndex]))
        }
        return result
    }
    
}

