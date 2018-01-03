import Foundation

/// Conforming types can be used to animate values conforming to `VectorConvertible`.
public protocol ValueAnimation: Animation {
    
    /// The type of value to be animated.
    associatedtype Value: VectorConvertible
    
    /// The current value of the animation.
    var value: Value { get }
    
    /// The current velocity of the animation.
    var velocity: Value { get }
    
}
