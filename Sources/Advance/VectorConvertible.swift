/// Conforming types can be converted to and from vector types.
///
/// This is the single requirement for any type that is to be animated
/// by `Animator`, `Simulator`, or `Spring`.
public protocol VectorConvertible {
    
    /// The concrete VectorType implementation that can represent the 
    /// conforming type.
    associatedtype AnimatableData: VectorArithmetic
    
    /// The vector representation of this instance.
    var animatableData: AnimatableData { get set }
    
}

extension VectorConvertible where AnimatableData == Self {
    
    public var animatableData: Self {
        get {
            self
        }
        set {
            self = newValue
        }
    }
    
    public init(animatableData: Self) {
        self = animatableData
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
    
    public var animatableData: VectorPair<CGFloat, CGFloat> {
        get {
            VectorPair(
                first: width,
                second: height)
        }
        set {
            width = newValue.first
            height = newValue.second
        }
    }
    
    public init(animatableData: VectorPair<CGFloat, CGFloat>) {
        self.init(
            width: animatableData.first,
            height: animatableData.second)
    }
    
}

/// Adds `VectorConvertible` conformance
extension CGPoint: VectorConvertible {    
    
    public var animatableData: VectorPair<CGFloat, CGFloat> {
        get {
            VectorPair(
                first: x,
                second: y)
        }
        set {
            x = newValue.first
            y = newValue.second
        }

    }
    
    public init(animatableData: VectorPair<CGFloat, CGFloat>) {
        self.init(
            x: animatableData.first,
            y: animatableData.second)
    }
    
}

/// Adds `VectorConvertible` conformance
extension CGRect: VectorConvertible {
    
    public init(animatableData: VectorPair<CGPoint.AnimatableData, CGSize.AnimatableData>) {
        self.init(
            origin: CGPoint(animatableData: animatableData.first),
            size: CGSize(animatableData: animatableData.second))
    }
    
    public var animatableData: VectorPair<CGPoint.AnimatableData, CGSize.AnimatableData> {
        get {
            VectorPair(
                first: origin.animatableData,
                second: size.animatableData)
        }
        set {
            origin.animatableData = newValue.first
            size.animatableData = newValue.second
        }

    }
}

#endif
