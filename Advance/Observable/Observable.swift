import Foundation

/// A simple EventType implementation.
public final class Observable<T> {
    
    public typealias Observer = (T) -> Void
    public typealias Token = UUID
    
    fileprivate var observers: [Token:Observer] = [:]
    
    /// Notifies observers.
    ///
    /// If the event has been closed, this has no effect.
    ///
    /// - parameter value: A value to be passed to each observer.
    fileprivate func send(value: T) {
        for o in observers.values {
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
    @discardableResult
    public func observe(_ observer: @escaping Observer) -> Token {
        let token = Token()
        observers[token] = observer
        return token
    }
    
    /// Removed an observer with a given token.
    ///
    /// - seeAlso: func observe(observer:key:)
    /// - parameter key: A string that identifies the observer to be removed.
    ///   If an observer does not exist for the given key, the method returns
    ///   without impact.
    public func removeObserver(for token: Token) {
        observers.removeValue(forKey: token)
    }
}

internal final class Sink<T> {
    
    let observable = Observable<T>()
    
    func send(value: T) {
        observable.send(value: value)
    }
    
}
