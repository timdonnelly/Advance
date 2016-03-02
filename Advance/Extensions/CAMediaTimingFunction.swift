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

import QuartzCore

extension CAMediaTimingFunction: TimingFunctionType {
    
    /// Solves for the given time with the specified precision.
    public func solveForTime(x: Scalar, epsilon: Scalar) -> Scalar {
        return unitBezier.solve(x, epsilon: epsilon)
    }
    
    /// Returns a `UnitBezier` instance created from this timing function's
    /// control points.
    public var unitBezier: UnitBezier {
        let pointsPointer1 = UnsafeMutablePointer<Float>.alloc(2)
        let pointsPointer2 = UnsafeMutablePointer<Float>.alloc(2)
        getControlPointAtIndex(1, values: pointsPointer1)
        getControlPointAtIndex(2, values: pointsPointer2)
        let b = UnitBezier(p1x: Scalar(pointsPointer1[0]), p1y: Scalar(pointsPointer1[1]), p2x: Scalar(pointsPointer2[0]), p2y: Scalar(pointsPointer2[1]))
        pointsPointer1.dealloc(2)
        pointsPointer2.dealloc(2)
        return b
    }
    
}