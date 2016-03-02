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

/// Animates changes to a value using spring physics.
///
/// Instances of `Spring` should be used in situations where spring physics
/// are the only animation type required, or when convenient access to the
/// properties of a running spring simulation is needed.
///
/// The focused API of this class makes it more convenient in such cases
/// than using an `Animatable` instance, where a new spring animation would
/// have to be added each time the spring needed to be modified.
///
/// ```
/// let s = Spring(value: CGPoint.zero)
///
/// s.changed.observe { (value) in
///   // do something with the value when it changes
/// }
///
/// s.target = CGPoint(x: 100.0, y: 200.0)
/// // Off it goes!
/// ```
public final class Spring<T: VectorConvertible> {
    
    private var solver: DynamicSolver<SpringFunction<T.Vector>> {
        didSet {
            lastNotifiedValue = T(vector: solver.value)
            if solver.settled == false && subscription.paused == true {
                subscription.paused = false
            }
        }
    }
    
    private lazy var subscription: LoopSubscription = {
        let s = Loop.shared.subscribe()
        
        s.advanced.observe({ [unowned self] (elapsed) -> Void in
            self.solver.advance(elapsed)
            if self.solver.settled {
                self.subscription.paused = true
            }
        })
        
        return s
    }()
    
    /// Fires when `value` has changed.
    public let changed = Event<T>()
    
    private var lastNotifiedValue: T {
        didSet {
            guard lastNotifiedValue != oldValue else { return }
            changed.fire(lastNotifiedValue)
        }
    }
    
    /// Creates a new `Spring` instance
    ///
    /// - parameter value: The initial value of the spring. The spring will be
    ///   initialized with `target` and `value` equal to the given value, and
    ///   a velocity of `0`.
    public init(value: T) {
        let f = SpringFunction(target: value.vector)
        solver = DynamicSolver(function: f, value: value.vector)
        lastNotifiedValue = value
    }
    
    /// Removes any current velocity and snaps the spring directly to the given value.
    public func reset(value: T) {
        var f = solver.function
        f.target = value.vector
        solver = DynamicSolver(function: f, value: value.vector)
        lastNotifiedValue = value
    }
    
    /// The current value of the spring.
    public var value: T {
        get { return T(vector: solver.value) }
        set { solver.value = newValue.vector }
    }
    
    /// The current velocity of the simulation.
    public var velocity: T {
        get { return T(vector: solver.velocity) }
        set { solver.velocity = newValue.vector }
    }
    
    /// The target value of the spring. As the simulation runs, `value` will be 
    /// pulled toward this value.
    public var target: T {
        get { return T(vector: solver.function.target) }
        set { solver.function.target = newValue.vector }
    }
    
    /// Configuration options for the spring.
    public var configuration: SpringConfiguration {
        get { return solver.function.configuration }
        set { solver.function.configuration = newValue }
    }
}