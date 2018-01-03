import QuartzCore

extension CAMediaTimingFunction: TimingFunction {
    
    /// Solves for the given time with the specified precision.
    public func solve(at time: Scalar, epsilon: Scalar) -> Scalar {
        return unitBezier.solve(x: time, epsilon: epsilon)
    }
    
    /// Returns a `UnitBezier` instance created from this timing function's
    /// control points.
    public var unitBezier: UnitBezier {
        let pointsPointer1 = UnsafeMutablePointer<Float>.allocate(capacity: 2)
        let pointsPointer2 = UnsafeMutablePointer<Float>.allocate(capacity: 2)
        getControlPoint(at: 1, values: pointsPointer1)
        getControlPoint(at: 2, values: pointsPointer2)
        let b = UnitBezier(firstX: Scalar(pointsPointer1[0]), firstY: Scalar(pointsPointer1[1]), secondX: Scalar(pointsPointer2[0]), secondY: Scalar(pointsPointer2[1]))
        pointsPointer1.deallocate(capacity: 2)
        pointsPointer2.deallocate(capacity: 2)
        return b
    }
    
}
