/// Conforming types can be linearly interpolated.
public protocol Interpolatable {
    
    /// Interpolate between the given values.
    ///
    /// - parameter from: The value to interpolate from.
    /// - parameter to: The value to interpolate to.
    /// - parameter alpha: The amount to interpolate between `from` and `to`, 
    ///   where 0.0 is fully weighted toward `from`, and 1.0 is fully weighted
    ///   toward `to`.
    /// - Returns: The interpolated result.
    func interpolated(to otherValue: Self, alpha: Scalar) -> Self
    
}
