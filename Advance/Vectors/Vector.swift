/// The underlying type of scalar quantities.
public typealias Scalar = Double

/// Conforming types can be operated on as vectors composed of `Scalar` components.
public protocol Vector: Equatable, Interpolatable, VectorMathCapable {
    
    /// Creates a vector for which all components are equal to the given scalar.
    init(scalar: Scalar)
    
    /// The number of scalar components in this vector type.
    static var length: Int { get }
    
    /// The empty vector (all scalar components are equal to `0.0`).
    static var zero: Self { get }
    
    /// Subscripting for vector components.
    subscript(index: Int) -> Scalar { get set }
    
    /// Returns a vector where each component is clamped by the corresponding
    /// components in `min` and `max`.
    ///
    /// - parameter x: The vector to be clamped.
    /// - parameter min: Each component in the output vector will `>=` the
    ///   corresponding component in this vector.
    /// - parameter max: Each component in the output vector will be `<=` the
    ///   corresponding component in this vector.
    func clamped(min: Self, max: Self) -> Self
    
    /// Clamps in place.
    mutating func clamp(min: Self, max: Self)
}


public extension Vector {
    
    /// Returns a vector where each component is clamped by the corresponding
    /// components in `min` and `max`.
    public func clamped(min: Self, max: Self) -> Self {
        var result = self
        for i in 0..<Self.length {
            if result[i] < min[i] { result[i] = min[i] }
            if result[i] > max[i] { result[i] = max[i] }
        }
        return result
    }
    
    /// Clamps in place.
    public mutating func clamp(min: Self, max: Self) {
        self = clamped(min: min, max: max)
    }
}
