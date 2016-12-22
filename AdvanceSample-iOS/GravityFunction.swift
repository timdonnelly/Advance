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

import Advance
import Foundation

struct GravityFunction: DynamicFunctionType {
    
    typealias Vector = Vector2
    
    var target: Vector
    
    var minRadius = 30.0
    
    var threshold: Scalar = 0.1
    
    init(target: Vector) {
        self.target = target
    }
    
    func acceleration(_ value: Vector, velocity: Vector) -> Vector {
        
        let delta = target - value
        let heading = atan2(delta.y, delta.x)
        
        var distance = hypot(delta.x, delta.y)
        distance = max(distance, minRadius)
        
        let accel = 1000000.0 / (distance*distance)
        
        var result = Vector.zero
        result.x = accel * cos(heading)
        result.y = accel * sin(heading)
        return result
    }
    
    func canSettle(_ value: Vector, velocity: Vector) -> Bool {
        let min = Vector(scalar: -threshold)
        let max = Vector(scalar: threshold)
        
        if velocity.clamped(min: min, max: max) != velocity {
            return false
        }
        
        let valueDelta = value - target
        if valueDelta.clamped(min: min, max: max) != valueDelta {
            return false
        }
        
        return true
    }
    
    func settledValue(_ value: Vector, velocity: Vector) -> Vector {
        return target
    }
}
