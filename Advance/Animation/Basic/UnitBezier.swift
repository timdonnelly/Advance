/*

Copyright (c) 2016, Storehouse Media Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

import Foundation
import CoreGraphics


/// A bezier curve, often used to calculate timing functions.
public struct UnitBezier {
    
    /// The horizontal component of the first control point.
    public var p1x: Scalar
    
    /// The vertical component of the first control point.
    public var p1y: Scalar
    
    /// The horizontal component of the second control point.
    public var p2x: Scalar
    
    /// The vertical component of the second control point.
    public var p2y: Scalar
    
    /// Creates a new `UnitBezier` instance.
    public init(p1x: Scalar, p1y: Scalar, p2x: Scalar, p2y: Scalar) {
        self.p1x = p1x
        self.p1y = p1y
        self.p2x = p2x
        self.p2y = p2y
    }
    
    /// Calculates the resulting `y` for given `x`.
    ///
    /// - parameter x: The value to solve for.
    /// - parameter epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated).
    /// - returns: The solved `y` value.
    public func solve(x: Scalar, epsilon: Scalar) -> Scalar {
        return UnitBezierSolver(bezier: self).solve(x, eps: epsilon)
    }
}

extension UnitBezier: Equatable { }

/// Equatable.
public func ==(lhs: UnitBezier, rhs: UnitBezier) -> Bool {
    return lhs.p1x == rhs.p1x
        && lhs.p1y == rhs.p1y
        && lhs.p2x == rhs.p2x
        && lhs.p2y == rhs.p2y
}


// Ported to Swift from WebCore:
// http://opensource.apple.com/source/WebCore/WebCore-955.66/platform/graphics/UnitBezier.h

/*
* Copyright (C) 2008 Apple Inc. All Rights Reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


private struct UnitBezierSolver {
    
    private let ax: Scalar
    private let bx: Scalar
    private let cx: Scalar
    
    private let ay: Scalar
    private let by: Scalar
    private let cy: Scalar
    
    init(bezier: UnitBezier) {
        self.init(p1x: bezier.p1x, p1y: bezier.p1y, p2x: bezier.p2x, p2y: bezier.p2y)
    }
    
    init(p1x: Scalar, p1y: Scalar, p2x: Scalar, p2y: Scalar) {
        
        // Calculate the polynomial coefficients, implicit first and last control points are (0,0) and (1,1).
        cx = 3.0 * p1x
        bx = 3.0 * (p2x - p1x) - cx
        ax = 1.0 - cx - bx
        
        cy = 3.0 * p1y
        by = 3.0 * (p2y - p1y) - cy
        ay = 1.0 - cy - by
    }
    
    func sampleCurveX(t: Scalar) -> Scalar {
        return ((ax * t + bx) * t + cx) * t
    }
    
    func sampleCurveY(t: Scalar) -> Scalar {
        return ((ay * t + by) * t + cy) * t
    }
    
    func sampleCurveDerivativeX(t: Scalar) -> Scalar {
        return (3.0 * ax * t + 2.0 * bx) * t + cx
    }
    
    func solveCurveX(x: Scalar, eps: Scalar) -> Scalar {
        var t0: Scalar = 0.0
        var t1: Scalar = 0.0
        var t2: Scalar = 0.0
        var x2: Scalar = 0.0
        var d2: Scalar = 0.0
        
        // First try a few iterations of Newton's method -- normally very fast.
        t2 = x
        for _ in 0..<8 {
            x2 = sampleCurveX(t2) - x
            if abs(x2) < eps {
                return t2
            }
            d2 = sampleCurveDerivativeX(t2)
            if abs(d2) < 1e-6 {
                break
            }
            t2 = t2 - x2 / d2
        }
        
        // Fall back to the bisection method for reliability.
        t0 = 0.0
        t1 = 1.0
        t2 = x
        
        if t2 < t0 {
            return t0
        }
        if t2 > t1 {
            return t1
        }
        
        while t0 < t1 {
            x2 = sampleCurveX(t2)
            if abs(x2-x) < eps {
                return t2
            }
            if x > x2 {
                t0 = t2
            } else {
                t1 = t2
            }
            t2 = (t1-t0) * 0.5 + t0
        }
        
        return t2
    }
    
    func solve(x: Scalar, eps: Scalar) -> Scalar {
        return sampleCurveY(solveCurveX(x, eps: eps))
    }
}
