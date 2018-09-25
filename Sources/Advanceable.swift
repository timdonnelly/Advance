/// Conforming types support advancing their state by a time interval.
public protocol Advanceable {
    
    /// Advance the state of the receiver by the given time interval in seconds.
    ///
    /// - parameter elapsed: The length of time that the animation should
    ///   be advanced by.
    mutating func advance(by time: Double)
    
}
