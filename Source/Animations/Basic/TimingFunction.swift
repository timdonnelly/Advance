import Foundation
import CoreGraphics

/// Conforming types can be used to convert linear input time (`0.0 -> 1.0`) to transformed output time (also `0.0 -> 1.0`).
public protocol TimingFunction {
    
    /// Transforms the given time.
    ///
    /// - parameter x: The input time (ranges between 0.0 and 1.0).
    /// - parameter epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated).
    /// - returns: The resulting output time.
    func solve(at time: Scalar, epsilon: Scalar) -> Scalar
}

/// Returns the input time, unmodified.
public struct LinearTimingFunction: TimingFunction {
    
    /// Creates a new instance of `LinearTimingFunction`.
    public init(){}
    
    /// Solves for time `x`.
    public func solve(at time: Scalar, epsilon: Scalar) -> Scalar {
        return time
    }
}

extension UnitBezier: TimingFunction {
    
    /// Solves for time `x`.
    public func solve(at time: Scalar, epsilon: Scalar) -> Scalar {
        return solve(x: time, epsilon: epsilon)
    }
}

public extension UnitBezier {
    
    /// Equivalent to `kCAMediaTimingFunctionEaseIn`.
    public static var easeIn: UnitBezier {
        return UnitBezier(firstX: 0.42, firstY: 0.0, secondX: 1.0, secondY: 1.0)
    }
    
    /// Equivalent to `kCAMediaTimingFunctionEaseOut`.
    public static var easeOut: UnitBezier {
        return UnitBezier(firstX: 0.0, firstY: 0.0, secondX: 0.58, secondY: 1.0)
    }
    
    /// Equivalent to `kCAMediaTimingFunctionEaseInEaseOut`.
    public static var easeInEaseOut: UnitBezier {
        return UnitBezier(firstX: 0.42, firstY: 0.0, secondX: 0.58, secondY: 1.0)
    }
    
    /// No easing.
    public static var linear: UnitBezier {
        return UnitBezier(firstX: 0.0, firstY: 0.0, secondX: 1.0, secondY: 1.0)
    }
    
    /// Inspired by the default curve in Google Material Design.
    public static var swiftOut: UnitBezier {
        return UnitBezier(firstX: 0.4, firstY: 0.0, secondX: 0.2, secondY: 1.0)
    }
    
}
