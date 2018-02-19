/// A protocol which defines the basic requirements to function as a
/// time-advancable animation.
///
/// Conforming types can be used to animate values.
public protocol Animation: Advanceable {
    
    /// The type of value to be animated.
    associatedtype Result
    
    /// Returns `True` if the animation has completed. 
    ///
    /// After the animation finishes, it should not return to an unfinished 
    /// state. Doing so may result in undefined behavior.
    var isFinished: Bool { get }
    
    /// The current value of the animation.
    var value: Result { get }
    
}

public extension Animation {
    
    /// Returns a sequence containing discrete values for the duration of the animation, based
    /// on the provided time step.
    public func allValues(timeStep: Double = 0.008) -> AnySequence<Result> {
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
    
    public mutating func next() -> T.Result? {
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
