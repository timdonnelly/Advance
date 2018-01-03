/// A simple EventType implementation.
public final class Event<T> {
    
    public typealias Observer = (T) -> Void
    
    fileprivate var observers: [Observer] = []
    fileprivate var keyedObservers: [String:Observer] = [:]
    
    /// Notifies observers.
    ///
    /// If the event has been closed, this has no effect.
    ///
    /// - parameter payload: A value to be passed to each observer.
    public func fire(value: T) {
        deliver(value: value)
    }

    fileprivate func deliver(value: T) {
        for o in observers {
            o(value)
        }
        for o in keyedObservers.values {
            o(value)
        }
    }
    
    /// Adds an observer.
    ///
    /// Adding an observer after an event is closed will simply call the
    /// observer synchronously with the payload that the event was closed
    /// with.
    ///
    /// - parameter observer: A closure that will be executed when this event
    ///   is fired.
    public func observe(_ observer: @escaping Observer) {
        observers.append(observer)
    }
    
    /// Adds an observer for a key.
    ///
    /// Adding an observer after an event is closed will simply call the
    /// observer synchronously with the payload that the event was closed
    /// with.
    ///
    /// - seeAlso: func unobserve(key:)
    /// - parameter observer: A closure that will be executed when this event
    ///   is fired.
    /// - parameter key: A string that identifies this observer, which can
    ///   be used to remove the observer.
    public func observe(_ observer: @escaping Observer, key: String) {
        keyedObservers[key] = observer
    }
    
    /// Removed an observer with a given key.
    ///
    /// - seeAlso: func observe(observer:key:)
    /// - parameter key: A string that identifies the observer to be removed.
    ///   If an observer does not exist for the given key, the method returns
    ///   without impact.
    public func removeObserver(for key: String) {
        keyedObservers.removeValue(forKey: key)
    }
}
