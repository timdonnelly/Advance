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


/// Provides type erasure for an animation conforming to ValueAnimationType
///
/// - parameter Value: The type of value to be animated.
public struct AnyValueAnimation<Value: VectorConvertible>: ValueAnimationType {
    
    /// The current value of the animation.
    public let value: Value
    
    /// The current value of the animation.
    public let velocity: Value
    
    /// `true` if the animation has finished.
    public let finished: Bool
    
    // Captures the underlying animation and allows us to advance it.
    private let advanceFunction: (Double) -> AnyValueAnimation<Value>
    
    /// Creates a new type-erased animation.
    ///
    /// - parameter animation: The animation to be type erased.
    public init<A: ValueAnimationType where A.Value == Value>(animation: A) {
        value = animation.value
        velocity = animation.velocity
        finished = animation.finished
        advanceFunction = { (time: Double) -> AnyValueAnimation<Value> in
            var a = animation
            a.advance(time)
            return AnyValueAnimation(animation: a)
        }
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(time: Double) {
        self = advanceFunction(time)
    }
}