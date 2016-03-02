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

/// Gradually reduces velocity until it equals `Vector.zero`.
public struct DecayFunction<Vector: VectorType>: DynamicFunctionType {
    
    /// How close to 0 each component of the velocity must be before the
    /// simulation is allowed to settle.
    public var threshold: Scalar = 0.1
    
    /// How much to erode the velocity.
    public var drag: Scalar = 3.0
    
    /// Creates a new `DecayFunction` instance.
    public init() {}
    
    /// Calculates acceleration for a given state of the simulation.
    public func acceleration(value: Vector, velocity: Vector) -> Vector {
        return -drag * velocity
    }
    
    /// Returns `true` if the simulation can become settled.
    public func canSettle(value: Vector, velocity: Vector) -> Bool {
        let min = Vector(scalar: -threshold)
        let max = Vector(scalar: threshold)
        return velocity.clamped(min: min, max: max) == velocity
    }
    
    /// Returns the value to settle on.
    public func settledValue(value: Vector, velocity: Vector) -> Vector {
        return value
    }
}