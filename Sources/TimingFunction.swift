import Foundation
import CoreGraphics

/// Conforming types can be used to convert linear input time (`0.0 -> 1.0`) to transformed output time (also `0.0 -> 1.0`).
public protocol TimingFunction {
    
    /// Transforms the given time.
    ///
    /// - parameter x: The input time (ranges between 0.0 and 1.0).
    /// - parameter epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated).
    /// - returns: The resulting output time.
    func solve(at time: Double, epsilon: Double) -> Double
}

/// Returns the input time, unmodified.
public struct LinearTimingFunction: TimingFunction {
    
    /// Creates a new instance of `LinearTimingFunction`.
    public init(){}
    
    /// Solves for time `x`.
    public func solve(at time: Double, epsilon: Double) -> Double {
        return time
    }
}

extension UnitBezier: TimingFunction {
    
    /// Solves for time `x`.
    public func solve(at time: Double, epsilon: Double) -> Double {
        return solve(x: time, epsilon: epsilon)
    }
}

extension UnitBezier {
    
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

#if canImport(QuartzCore)

import QuartzCore

extension CAMediaTimingFunction: TimingFunction {
    
    /// Solves for the given time with the specified precision.
    public func solve(at time: Double, epsilon: Double) -> Double {
        return unitBezier.solve(x: time, epsilon: epsilon)
    }
    
    /// Returns a `UnitBezier` instance created from this timing function's
    /// control points.
    public var unitBezier: UnitBezier {
        return UnitBezier(firstX: controlPoints[1].x,
                          firstY: controlPoints[1].y,
                          secondX: controlPoints[2].x,
                          secondY: controlPoints[2].y)
    }
    
    private var controlPoints: [(x: Double, y: Double)] {
        return (0...3).map { (index) in
            
            var rawValues: [Float] = [0.0, 0.0]
            getControlPoint(at: index, values: &rawValues)
            
            return (x: Double(rawValues[0]), y: Double(rawValues[1]))
        }
    }
    
}

#endif
