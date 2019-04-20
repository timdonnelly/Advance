import Foundation
import CoreGraphics

/// Timing functions are used to convert linear input time (`0.0 -> 1.0`) to transformed output time (also `0.0 -> 1.0`).
public enum TimingFunction {
    
    /// No easing
    case linear
    
    /// The given unit bezier will be used to drive the timing function
    case bezier(UnitBezier)
    
    /// Initializes a bezier timing function with the given control points.
    public init(x1: Double, y1: Double, x2: Double, y2: Double) {
        self = .bezier(UnitBezier(firstX: x1, firstY: y1, secondX: x2, secondY: y2))
    }
    
    /// Transforms the given time.
    ///
    /// - parameter x: The input time (ranges between 0.0 and 1.0).
    /// - parameter epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated).
    /// - returns: The resulting output time.
    public func solve(at time: Double, epsilon: Double) -> Double {
        switch self {
        case .linear:
            return time
        case .bezier(let unitBezier):
            return unitBezier.solve(x: time, epsilon: epsilon)
        }
    }
}

extension TimingFunction {
    
    /// Equivalent to `kCAMediaTimingFunctionEaseIn`.
    public static var easeIn: TimingFunction {
        return TimingFunction(x1: 0.42, y1: 0.0, x2: 1.0, y2: 1.0)
    }
    
    /// Equivalent to `kCAMediaTimingFunctionEaseOut`.
    public static var easeOut: TimingFunction {
        return TimingFunction(x1: 0.0, y1: 0.0, x2: 0.58, y2: 1.0)
    }
    
    /// Equivalent to `kCAMediaTimingFunctionEaseInEaseOut`.
    public static var easeInEaseOut: TimingFunction {
        return TimingFunction(x1: 0.42, y1: 0.0, x2: 0.58, y2: 1.0)
    }
    
    /// Inspired by the default curve in Google Material Design.
    public static var swiftOut: TimingFunction {
        return TimingFunction(x1: 0.4, y1: 0.0, x2: 0.2, y2: 1.0)
    }
    
}

#if canImport(QuartzCore)

import QuartzCore

extension TimingFunction {
    
    /// Initializes a timing function with a unit bezier derived from the given Core Animation timing function.
    public init(coreAnimationTimingFunction: CAMediaTimingFunction) {
        let controlPoints: [(x: Double, y: Double)] = (0...3).map { (index) in
            var rawValues: [Float] = [0.0, 0.0]
            coreAnimationTimingFunction.getControlPoint(at: index, values: &rawValues)
            return (x: Double(rawValues[0]), y: Double(rawValues[1]))
        }
        
        self.init(
            x1: controlPoints[1].x,
            y1: controlPoints[1].y,
            x2: controlPoints[2].x,
            y2: controlPoints[2].y)
    }
    
}

#endif
