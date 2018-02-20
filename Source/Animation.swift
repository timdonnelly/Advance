/// A protocol which defines the basic requirements to function as a
/// time-advancable animation.
///
/// Conforming types can be used to animate values.
public protocol Animation: Advanceable {
    
    /// The type of value to be animated.
    associatedtype Value: VectorConvertible
    
    /// Returns `true` if the animation has completed.
    var isFinished: Bool { get }
    
    /// The current value of the animation.
    var value: Value { get }
    
    /// The current velocity of the animation. This can be used to achieve seamless transitions between animations.
    /// For example, a running spring animation may be interrupted and replaced by a decay animation. The velocity of
    /// the spring at the time it is interrupted can be used as the initial velocity of the decay animation to produce
    /// fluid, continuous motion.
    var velocity: Value { get }
    
}


public extension Animation {
    
    /// Returns a sequence containing discrete values for the duration of the animation, based
    /// on the provided time step.
    public func allValues(timeStep: Double = 0.008) -> AnySequence<Value> {
        return AnySequence.init({ () -> AnimationIterator<Self> in
            return AnimationIterator(animation: self, timeStep: timeStep)
        })
    }
    
}

fileprivate struct AnimationIterator<T>: IteratorProtocol where T: Animation {
    
    private var animation: T?
    private let timeStep: Double
    
    fileprivate init(animation: T, timeStep: Double) {
        self.animation = animation
        self.timeStep = timeStep
    }
    
    public mutating func next() -> T.Value? {
        guard var currentAnimation = animation else { return nil }
        let result = currentAnimation.value
        
        if currentAnimation.isFinished {
            self.animation = nil
        } else {
            currentAnimation.advance(by: timeStep)
            self.animation = currentAnimation
        }
        
        return result
    }
    
}
