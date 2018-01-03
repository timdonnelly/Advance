/// A protocol which defines the basic requirements to function as a
/// time-advancable animation.
public protocol Animation: Advanceable {
    
    /// Returns `True` if the animation has completed. 
    ///
    /// After the animation finishes, it should not return to an unfinished 
    /// state. Doing so may result in undefined behavior.
    var finished: Bool { get }
    
}

