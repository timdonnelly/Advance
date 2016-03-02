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

/// Interpolates between values over a specified duration.
///
/// - parameter Value: The type of value to be animated.
public struct BasicAnimation<Value: VectorConvertible>: ValueAnimationType {
    
    /// The initial value at time 0.
    private (set) public var from: Value
    
    /// The final value when the animation is finished.
    private (set) public var to: Value
    
    /// The duration of the animation in seconds.
    private (set) public var duration: Double
    
    /// The timing function that is used to map elapsed time to an
    /// interpolated value.
    private (set) public var timingFunction: TimingFunctionType
    
    /// Creates a new `BasicAnimation` instance.
    ///
    /// - parameter from: The value at time `0`.
    /// - parameter to: The value at the end of the animation.
    /// - parameter duration: How long (in seconds) the animation should last.
    /// - parameter timingFunction: The timing function to use.
    public init(from: Value, to: Value, duration: Double, timingFunction: TimingFunctionType = UnitBezier(preset: .SwiftOut)) {
        self.from = from
        self.to = to
        self.duration = duration
        self.timingFunction = timingFunction
        self.value = from
        self.velocity = Value.zero
    }
    
    /// The current value.
    private(set) public var value: Value
    
    /// The current velocity.
    private(set) public var velocity: Value
    
    private var elapsed: Double = 0.0
    
    /// Returns `true` if the advanced time is `>=` duration.
    public var finished: Bool {
        return elapsed >= duration
    }
    
    /// Advances the animation.
    ///
    /// - parameter elapsed: The time (in seconds) to advance the animation.
    public mutating func advance(time: Double) {
        let starting = value
        
        elapsed += time
        var progress = elapsed / duration
        progress = max(progress, 0.0)
        progress = min(progress, 1.0)
        let adjustedProgress = timingFunction.solveForTime(Scalar(progress), epsilon: 1.0 / Scalar(duration * 1000.0))
        
        let val = from.vector.interpolatedTo(to.vector, alpha: Scalar(adjustedProgress))
        value = Value(vector: val)

        let vel = Scalar(1.0/time) * (value.vector - starting.vector)
        velocity = Value(vector: vel)
    }
    
}


public extension Animatable {
    
    /// Animates to the specified value, using a default duration and timing
    /// function.
    ///
    /// - parameter to: The value to animate to.
    /// - parameter completion: An optional closure that will be called when
    ///   the animation completes.
    public func animateTo(to: Value, completion: Completion? = nil) {
        animateTo(to, duration: 0.25, timingFunction: UnitBezier(preset: .SwiftOut), completion: completion)
    }
    
    /// Animates to the specified value.
    ///
    /// - parameter to: The value to animate to.
    /// - parameter duration: The duration of the animation.
    /// - parameter timingFunction: The timing (easing) function to use.
    /// - parameter completion: An optional closure that will be called when
    ///   the animation completes.
    public func animateTo(to: Value, duration: Double, timingFunction: TimingFunctionType, completion: Completion? = nil) {
        let a = BasicAnimation(from: value, to: to, duration: duration, timingFunction: timingFunction)
        animate(a, completion: completion)
    }
    
}

public extension VectorConvertible {
    
    /// Animates to the specified value.
    ///
    /// - parameter to: The value to animate to.
    /// - parameter duration: The duration of the animation.
    /// - parameter timingFunction: The timing (easing) function to use.
    /// - parameter callback: A closure that will be called with the new value
    ///   for each frame of the animation until it is finished.
    /// - returns: The underlying animator.
    public func animateTo(to: Self, duration: Double, timingFunction: TimingFunctionType, callback: (Self)->Void) -> Animator<BasicAnimation<Self>> {
        let a = BasicAnimation(from: self, to: to, duration: duration, timingFunction: timingFunction)
        let animator = AnimatorContext.shared.animate(a)
        animator.changed.observe { (a) in
            callback(a.value)
        }
        return animator
    }
}