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

/// Output time is calculated as `(1.0-x)`.
public struct ReversedTimingFunction: TimingFunction {
    /// Creates a new instance of `ReversedTimingFunction`.
    public init(){}
    
    /// Solves for time `x`.
    public func solve(at time: Scalar, epsilon: Scalar) -> Scalar {
        return 1.0 - time
    }
}


extension UnitBezier: TimingFunction {
    
    /// Solves for time `x`.
    public func solve(at time: Scalar, epsilon: Scalar) -> Scalar {
        return solve(x: time, epsilon: epsilon)
    }
}

public extension UnitBezier {
    
    /// A set of preset bezier curves.
    public enum Preset {
        /// Equivalent to `kCAMediaTimingFunctionDefault`.
        case `default`
        
        /// Equivalent to `kCAMediaTimingFunctionEaseIn`.
        case easeIn
        
        /// Equivalent to `kCAMediaTimingFunctionEaseOut`.
        case easeOut
        
        /// Equivalent to `kCAMediaTimingFunctionEaseInEaseOut`.
        case easeInEaseOut
        
        /// No easing.
        case linear
        
        /// Inspired by the default curve in Google Material Design.
        case swiftOut
    }
    
    /// Initializes a UnitBezier with a preset.
    public init(preset: Preset) {
        switch preset {
        case .default:
            self = UnitBezier(firstX: 0.25, firstY: 0.1, secondX: 0.25, secondY: 1.0)
        case .easeIn:
            self =  UnitBezier(firstX: 0.42, firstY: 0.0, secondX: 1.0, secondY: 1.0)
        case .easeOut:
            self =  UnitBezier(firstX: 0.0, firstY: 0.0, secondX: 0.58, secondY: 1.0)
        case .easeInEaseOut:
            self =  UnitBezier(firstX: 0.42, firstY: 0.0, secondX: 0.58, secondY: 1.0)
        case .linear:
            self =  UnitBezier(firstX: 0.0, firstY: 0.0, secondX: 1.0, secondY: 1.0)
        case .swiftOut:
            self =  UnitBezier(firstX: 0.4, firstY: 0.0, secondX: 0.2, secondY: 1.0)
        }
    }
}
