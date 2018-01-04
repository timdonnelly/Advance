/// A protocol which defines the basic requirements to function as a
/// time-advancable animation.
///
/// Conforming types can be used to animate values conforming to `VectorConvertible`.
public protocol Animation: Advanceable {
    
    /// Returns `True` if the animation has completed. 
    ///
    /// After the animation finishes, it should not return to an unfinished 
    /// state. Doing so may result in undefined behavior.
    var finished: Bool { get }
    
    /// The type of value to be animated.
    associatedtype Value: VectorConvertible
    
    /// The current value of the animation.
    var value: Value { get }
    
    /// The current velocity of the animation.
    var velocity: Value { get }
    
}

