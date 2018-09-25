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
    public func steps(frameDuration: Double = 0.008) -> [(timeOffset: Double, value: Value, velocity: Value)] {
        let sequence = AnySequence.init({ () -> AnimationIterator<Self> in
            return AnimationIterator(animation: self, frameDuration: frameDuration)
        })
        return Array(sequence)
    }
    
}

fileprivate struct AnimationIterator<T>: IteratorProtocol where T: Animation {
    
    private var animation: T?
    private var currentTime: Double
    private let frameDuration: Double
    
    fileprivate init(animation: T, frameDuration: Double) {
        self.animation = animation
        self.currentTime = 0.0
        self.frameDuration = frameDuration
    }
    
    public mutating func next() -> (timeOffset: Double, value: T.Value, velocity: T.Value)? {
        guard var currentAnimation = animation else { return nil }
        let result = (timeOffset: currentTime, value: currentAnimation.value, velocity: currentAnimation.velocity)
        
        if currentAnimation.isFinished {
            self.animation = nil
        } else {
            currentAnimation.advance(by: frameDuration)
            currentTime += frameDuration
            self.animation = currentAnimation
        }
        
        return result
    }
    
}
