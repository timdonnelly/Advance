/// Conforming types can be converted to and from vector types.
///
/// This is the single requirement for any type that is to be animated
/// by `Animator`, `Simulator`, or `Spring`.
public protocol VectorConvertible: Equatable {
    
    /// The concrete VectorType implementation that can represent the 
    /// conforming type.
    associatedtype Vector: VectorArithmetic
    
    /// Creates a new instance from a vector.
    init(vector: Vector)
    
    /// The vector representation of this instance.
    var vector: Vector { get }
    
}

extension VectorConvertible {
    
    /// Returns an instance initialized using the zero vector.
    public static var zero: Self {
        return Self(vector: Vector.zero)
    }
}

extension VectorConvertible where Vector == Self {
    
    public var vector: Self {
        self
    }
    
    public init(vector: Self) {
        self = vector
    }
    
}

// This protocol is intentionally similar to `VectorArithmetic` from SwiftUI, which
// may be added as a dependency in a future release.
public protocol VectorArithmetic: AdditiveArithmetic {
    var magnitudeSquared: Double { get }
    mutating func scale(by magnitude: Double)
}

extension Double: VectorArithmetic {
    
    public var magnitudeSquared: Double {
        self * self
    }
    
    public mutating func scale(by magnitude: Double) {
        self *= magnitude
    }
    
}

public struct VectorPair<First: VectorArithmetic, Second: VectorArithmetic>: VectorArithmetic {

    public var first: First
    public var second: Second
    
    public init(first: First, second: Second) {
        self.first = first
        self.second = second
    }
    
    public var magnitudeSquared: Double {
        first.magnitudeSquared + second.magnitudeSquared
    }
    
    public mutating func scale(by magnitude: Double) {
        first.scale(by: magnitude)
        second.scale(by: magnitude)
    }
    
    public static var zero: VectorPair<First, Second> {
        VectorPair(
            first: .zero,
            second: .zero)
    }
    
    public static func - (lhs: VectorPair<First, Second>, rhs: VectorPair<First, Second>) -> VectorPair<First, Second> {
        VectorPair(
            first: lhs.first - rhs.first,
            second: lhs.second - rhs.second)
    }
    
    public static func -= (lhs: inout VectorPair<First, Second>, rhs: VectorPair<First, Second>) {
        lhs.first -= rhs.first
        lhs.second -= rhs.second
    }
    
    public static func + (lhs: VectorPair<First, Second>, rhs: VectorPair<First, Second>) -> VectorPair<First, Second> {
        VectorPair(
            first: lhs.first + rhs.first,
            second: lhs.second + rhs.second)
    }
    
    public static func += (lhs: inout VectorPair<First, Second>, rhs: VectorPair<First, Second>) {
        lhs.first += rhs.first
        lhs.second += rhs.second
    }
    
}


/// ********************************************************************************
/// VectorConvertible conformance extensions
/// ********************************************************************************

/// Adds `VectorConvertible` conformance
extension Double: VectorConvertible {}

#if canImport(CoreGraphics)

import CoreGraphics

extension CGFloat: VectorArithmetic, VectorConvertible {
    
    public var magnitudeSquared: Double {
        Double(self * self)
    }
    
    public mutating func scale(by magnitude: Double) {
        self *= CGFloat(magnitude)
    }
    
}

/// Adds `VectorConvertible` conformance
extension CGSize: VectorConvertible {
    
    public var vector: VectorPair<CGFloat, CGFloat> {
        VectorPair(
            first: width,
            second: height)
    }
    
    public init(vector: VectorPair<CGFloat, CGFloat>) {
        self.init(
            width: vector.first,
            height: vector.second)
    }
    
}

/// Adds `VectorConvertible` conformance
extension CGPoint: VectorConvertible {
    
    public var vector: VectorPair<CGFloat, CGFloat> {
        VectorPair(
            first: x,
            second: y)
    }
    
    public init(vector: VectorPair<CGFloat, CGFloat>) {
        self.init(
            x: vector.first,
            y: vector.second)
    }
    
}

/// Adds `VectorConvertible` conformance
extension CGRect: VectorConvertible {
    
    public init(vector: VectorPair<CGPoint.Vector, CGSize.Vector>) {
        self.init(
            origin: CGPoint(vector: vector.first),
            size: CGSize(vector: vector.second))
    }
    
    public var vector: VectorPair<CGPoint.Vector, CGSize.Vector> {
        VectorPair(
            first: origin.vector,
            second: size.vector)
    }
}

#endif
