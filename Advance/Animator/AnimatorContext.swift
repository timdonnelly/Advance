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

/// Creates and manages `Animator` instances, retaining them until completion.
public final class AnimatorContext {
    
    /// The default context.
    public static let shared = AnimatorContext()
    
    private var animators: Set<AnimatorWrapper> = []
    
    /// Creates a new animator context.
    public init() {}
    
    deinit {
        for a in animators {
            a.animator.cancel()
        }
    }
    
    /// Generates a new animator instance to run the given animation.
    ///
    /// - parameter animation: The animation to run.
    /// - returns: The newly generated `Animator` instance.
    public func animate<A: AnimationType>(animation: A) -> Animator<A> {
        let a = Animator(animation: animation)
        a.start()
        if a.state == .Running {
            let wrapper = AnimatorWrapper(animator: a)
            animators.insert(wrapper)
            let obs: (A)->Void = { [weak self] (a) -> Void in
                self?.animators.remove(wrapper)
            }
            a.cancelled.observe(obs)
            a.finished.observe(obs)
        }
        return a
    }
}

private protocol AnimatorType: class {
    func cancel()
}

extension Animator: AnimatorType {}

private struct AnimatorWrapper: Hashable {
    let animator: AnimatorType
    init<A: AnimationType>(animator: Animator<A>) {
        self.animator = animator
    }
    
    var hashValue: Int {
        return unsafeAddressOf(animator).hashValue
    }
}

private func ==(lhs: AnimatorWrapper, rhs: AnimatorWrapper) -> Bool {
    return lhs.animator === rhs.animator
}