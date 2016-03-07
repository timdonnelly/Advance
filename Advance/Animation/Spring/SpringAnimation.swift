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


/// The `SpringAnimation` struct is an implementation of
/// `ValueAnimationType` that uses a configurable spring function to animate
/// the value.
///
/// Spring animations do not have a duration. Instead, you should configure
/// the properties in 'configuration' to customize the way the spring will
/// change the value as the simulation advances. The animation is finished
/// when the spring has come to rest at its target value.
///
/// SpringAnimation instances use a `DynamicSolver` containing a
/// `SpringFunction` internally to perform the spring calculations.
public struct SpringAnimation<Value: VectorConvertible>: ValueAnimationType {
    
    // The underlying spring simulation.
    private var solver: DynamicSolver<SpringFunction<Value.Vector>>
    
    /// Creates a new `SpringAnimation` instance.
    ///
    /// - parameter from: The value of the animation at time `0`.
    /// - parameter target: The final value that the spring will settle on at
    ///   the end of the animation.
    /// - parameter velocity: The initial velocity at the start of the animation.
    public init(from: Value, target: Value, velocity: Value = Value.zero) {
        let f = SpringFunction(target: target.vector)
        solver = DynamicSolver(function: f, value: from.vector, velocity: velocity.vector)
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(elapsed: Double) {
        solver.advance(elapsed)
    }
    
    /// Returns `true` if the spring has reached a settled state.
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
    
    
    /// The value that the spring will move toward.
    public var target: Value {
        get { return Value(vector: solver.function.target) }
        set { solver.function.target = newValue.vector }
    }
    
    /// The configuration of the underlying spring simulation.
    public var configuration: SpringConfiguration {
        get { return solver.function.configuration }
        set { solver.function.configuration = newValue }
    }
}


public extension Animatable {
    
    /// Animates to the given value using a spring function.
    ///
    /// - parameter to: The value to animate to.
    /// - parameter initialVelocity: An optional velocity to use at time `0`.
    ///   If no velocity is given, the current velocity of the `Animatable` instance
    ///   will be used (if another animation is in progress).
    /// - parameter configuration: A spring configuration instance to use.
    /// - parameter completion: A closure that will be called at the end of the
    ///   animation.
    public func springTo(to: Value, initialVelocity: Value? = nil, configuration: SpringConfiguration = SpringConfiguration(), completion: Completion? = nil) {
        var a = SpringAnimation(from: value, target: to, velocity: initialVelocity ?? velocity)
        a.configuration = configuration
        animate(a, completion: completion)
    }
}

public extension VectorConvertible {
    
    /// Animates to the given value using a spring function.
    ///
    /// - parameter to: The value to animate to.
    /// - parameter callback: A closure that will be called at each step of the animation.
    /// - returns: The animator instance that is powering the animation.
    public func springTo(to: Self, configuration: SpringConfiguration, callback: (Self) -> Void) -> Animator<SpringAnimation<Self>> {
        var a = SpringAnimation(from: self, target: to, velocity: Self.zero)
        a.configuration = configuration
        let animator = AnimatorContext.shared.animate(a)
        animator.changed.observe({ (a) -> Void in
            callback(a.value)
        })
        return animator
    }
    
}