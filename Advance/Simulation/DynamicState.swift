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


public struct DynamicState<VectorType: Vector> {
    
    public var value: VectorType
    
    public var velocity: VectorType
    
    public init(value: VectorType, velocity: VectorType) {
        self.value = value
        self.velocity = velocity
    }
    
}

extension DynamicState {
    
    /// RK4 Integration.
    public func integrate<F: DynamicFunction>(_ function: F, time: Double) -> DynamicState<VectorType> where F.VectorType == VectorType {
        
        let initial = Derivative(value:VectorType.zero, velocity: VectorType.zero)
        
        let a = evaluate(function, time: 0.0, derivative: initial)
        let b = evaluate(function, time: time * 0.5, derivative: a)
        let c = evaluate(function, time: time * 0.5, derivative: b)
        let d = evaluate(function, time: time, derivative: c)
        
        var dxdt = a.value
        dxdt += (2.0 * (b.value + c.value)) + d.value
        dxdt = Scalar(1.0/6.0) * dxdt
        
        var dvdt = a.velocity
        dvdt += (2.0 * (b.velocity + c.velocity)) + d.velocity
        dvdt = Scalar(1.0/6.0) * dvdt
        
        
        let val = value + Scalar(time) * dxdt
        let vel = velocity + Scalar(time) * dvdt
        
        return DynamicState(value: val, velocity: vel)
    }
    
    private typealias Derivative = DynamicState<VectorType>
    
    private func evaluate<F: DynamicFunction>(_ function: F, time: Double, derivative: Derivative) -> Derivative where F.VectorType == VectorType {
        let val = value + Scalar(time) * derivative.value
        let vel = velocity + Scalar(time) * derivative.velocity
        let accel = function.acceleration(state: DynamicState(value: val, velocity: vel))
        let d = Derivative(value: vel, velocity: accel)
        return d
    }
}
