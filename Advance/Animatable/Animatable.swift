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


/// Instances of `Animatable` wrap, and manage animated change to, a value 
/// conforming to `VectorConvertible`.
///
/// Using this class to represent a value is often cleaner than setting
/// up and managing animations independently, as `Animatable` conveniently
/// channels all changes to the value into the `changed` event. For example:
///
/// ``` 
/// class Foo {
///   let size: Animatable<CGSize>
///
///   (...)
///
///   init() {
///     size.changed.observe { [weak self] (val) in
///       self?.doSomethingWithSize(val)
///     }
///   }
/// }
///
/// let f = Foo()
/// f.size.animateTo(CGSize(width: 200.0, height: 200.0))
/// ```
///
public final class Animatable<Value: VectorConvertible> {
    
    /// `finished` will be true if the animation finished uninterrupted, or 
    /// false if it was cancelled.
    public typealias Completion = (finished: Bool) -> Void
    
    /// Fires each time the `value` property changes.
    public let changed = Event<Value>()
    
    // The animator that is driving the current animation, if any.
    private var animator: Animator<AnyValueAnimation<Value>>? = nil
    
    // Tracks the last publicly notified value – this lets us control when
    // events are fired (we always want to wait until the end of the
    // animation loop).
    private var currentValue: Value {
        didSet {
            guard currentValue != oldValue else { return }
            changed.fire(value)
        }
    }
    
    /// Returns `true` if an animation is in progress.
    public var animating: Bool {
        return animator != nil
    }
    
    /// The current value of this `Animatable`.
    /// 
    /// Setting this property will cancel any animation that is in
    /// progress, and this `Animatable` will assume the new value immediately.
    public var value: Value {
        get {
            return currentValue
        }
        set {
            cancelAnimation()
            currentValue = newValue
        }
    }
    
    /// The current velocity reported by the in-flight animation, if any. If no
    /// animation is in progress, the returned value will be equivalent to
    /// `T.Vector.zero`
    public var velocity: Value {
        return animator?.animation.velocity ?? Value.zero
    }
    
    /// Creates an `Animatable` of T initialized to an initial value.
    ///
    /// - parameter value: The initial value of this animatable.
    public required init(value: Value) {
        currentValue = value
    }
    
    deinit {
        // Make sure we property fire the completion block for the in-flight
        // animation.
        cancelAnimation()
    }
    
    /// Runs the given animation until is either completes or is removed (by
    /// starting another animation or by directly setting the value).
    ///
    /// - parameter animation: The animation to be run.
    /// - parameter completion: An optional closure that will be called when this 
    ///   animation has completed. Its only argument is a `Boolean`, which will 
    ///   be `true` if the animation completed uninterrupted, or `false` if it
    ///   was removed for any other reason.
    public func animate<A: ValueAnimationType where A.Value == Value>(animation: A, completion: Completion? = nil) {
        
        // Cancel any in-flight animation. We observe the cancelled event of
        // animators that we create in order to clean up, so this will have
        // the side effect of nilling the `animator` property.
        cancelAnimation()
        assert(animator == nil)
        
        animator = AnimatorContext.shared.animate(AnyValueAnimation(animation: animation))
        
        animator?.changed.observe({ [unowned self] (a) -> Void in
            self.currentValue = a.value
        })
        
        animator?.cancelled.observe({ [unowned self] (a) -> Void in
            self.animator = nil
            completion?(finished: false)
        })
        
        animator?.finished.observe({ [unowned self] (a) -> Void in
            self.animator = nil
            completion?(finished: true)
        })
    }
    
    /// Cancels an in-flight animation, if present.
    public func cancelAnimation() {
        animator?.cancel()
    }
}