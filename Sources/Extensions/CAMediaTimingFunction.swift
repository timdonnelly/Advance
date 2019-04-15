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
        return (0...3).lazy.map { (index) in
            
            var rawValues: [Float] = [0.0, 0.0]
            getControlPoint(at: index, values: &rawValues)
            
            return (x: Double(rawValues[0]), y: Double(rawValues[1]))
        }
    }
    
}
