/// A protocol which defines the basic requirements to function as a
/// time-advancable animation.
///
/// Conforming types can be used to animate values.
public protocol Animation: Advanceable {
    
    /// The type of value to be animated.
    associatedtype Element
    
    /// Returns `true` if the animation has completed.
    var isFinished: Bool { get }
    
    /// The current value of the animation.
    var value: Element { get }
    
}

public extension Animation {
    
    /// Returns a sequence containing discrete values for the duration of the animation, based
    /// on the provided time step.
    public func allValues(timeStep: Double = 0.008) -> AnySequence<Element> {
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
    
    public mutating func next() -> T.Element? {
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
