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

/// Given a starting velocity, `DecayAnimation` will slowly bring the value
/// to a stop (where `velocity` == `Value.zero`).
///
/// `DecayAnimation` uses a `DynamicSolver` containing a `DecayFunction`
/// internally.
public struct DecayAnimation<Value: VectorConvertible>: ValueAnimationType {
    
    private var solver: DynamicSolver<DecayFunction<Value.Vector>>
    
    /// Creates a new `DecayAnimation` instance.
    ///
    /// - parameter threshold: The minimum velocity, below which the animation
    ///   will finish.
    /// - parameter from: The initial value of the animation.
    /// - parameter velocity: The velocity at time `0`.
    public init(threshold: Scalar = 0.1, from: Value = Value.zero, velocity: Value = Value.zero) {
        var f = DecayFunction<Value.Vector>()
        f.threshold = threshold
        f.drag = 3.0
        solver = DynamicSolver(function: f, value: from.vector, velocity: velocity.vector)
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(elapsed: Double) {
        solver.advance(elapsed)
    }
    
    /// Returns `true` if the velocity has settled at 0.
    public var finished: Bool {
        return solver.settled
    }
    
    /// The current value.
    public var value: Value {
        get { return Value(vector: solver.value) }
        set { solver.value = newValue.vector }
    }
    
    /// The current velocity.
    public var velocity: Value {
        get { return Value(vector: solver.velocity) }
        set { solver.velocity = newValue.vector }
    }
    
    /// Each component of the simulation's velocity must be within this distance
    /// of 0.0 for the animation to complete.
    public var threshold: Scalar {
        get { return solver.function.threshold }
        set { solver.function.threshold = newValue }
    }
    
    /// The strength with which the velocity will be reduced. The acceleration
    /// for the simulation is calculated as `-drag * velocity`. Default: `3.0`.
    public var drag: Scalar {
        get { return solver.function.drag }
        set { solver.function.drag = newValue }
    }
}


public extension Animatable {
    
    /// Adds a decay animation, starting from the current value and velocity.
    ///
    /// - parameter drag: The amount of drag that will slow down the velocity.
    /// - parameter threshold: The settling threshold that determines how
    ///   close the velocity must be to `0` before the simulation is allowed
    ///   to settle.
    /// - parameter completion: An optional closure that will be called at
    ///   the end of the animation.
    public func decay(drag: Scalar, threshold: Scalar, completion: Completion? = nil) {
        decay(velocity, drag: drag, threshold: threshold, completion: completion)
    }
    
    /// Adds a decay animation, starting from the current value.
    ///
    /// - parameter velocity: The initial velocity at time `0`.
    /// - parameter drag: The amount of drag that will slow down the velocity.
    /// - parameter threshold: The settling threshold that determines how
    ///   close the velocity must be to `0` before the simulation is allowed
    ///   to settle.
    /// - parameter completion: An optional closure that will be called at
    ///   the end of the animation.
    public func decay(velocity: Value, drag: Scalar, threshold: Scalar, completion: Completion? = nil) {
        var d = DecayAnimation(threshold: threshold, from: value, velocity: velocity)
        d.drag = drag
        animate(d, completion: completion)
    }
    
}