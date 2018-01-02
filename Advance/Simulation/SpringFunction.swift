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
import QuartzCore

/// The configuration options for a spring function.
public struct SpringConfiguration {
    
    /// Strength of the spring.
    public var tension: Scalar = 120.0
    
    /// How damped the spring is.
    public var damping: Scalar = 12.0
    
    /// The minimum scalar distance used for settling the spring simulation.
    public var threshold: Scalar = 0.1
    
    /// Creates a new `SpringConfiguration` instance with default values.
    public init() {}
}

/// Implements a simple spring acceleration function.
public struct SpringFunction<VectorType: Vector>: DynamicFunction {
    
    /// The target of the spring.
    public var target: VectorType
    
    /// Configuration options.
    public var configuration: SpringConfiguration
    
    /// Creates a new `SpringFunction` instance.
    ///
    /// - parameter target: The target of the new instance.
    public init(target: VectorType) {
        self.target = target
        self.configuration = SpringConfiguration()
    }
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(state: DynamicState<VectorType>) -> VectorType {
        let delta = state.value - target
        let accel = (-configuration.tension * delta) - (configuration.damping * state.velocity)
        return accel
    }
    
    /// Returns `true` if the simulation can become settled.
    public func canSettle(state: DynamicState<VectorType>) -> Bool {
        let min = VectorType(scalar: -configuration.threshold)
        let max = VectorType(scalar: configuration.threshold)
        
        if state.velocity.clamped(min: min, max: max) != state.velocity {
            return false
        }
        
        let valueDelta = state.value - target
        if valueDelta.clamped(min: min, max: max) != valueDelta {
            return false
        }
        
        return true
    }
    
    /// Returns the value to settle on.
    public func settledValue(state: DynamicState<VectorType>) -> VectorType {
        return target
    }
}
