import Foundation



/// Represents a changing stream of values that can be observed.
public protocol Observable {
    
    /// The type of value that will be emitted by the observable type.
    associatedtype Value
    
    /// Observers are closures that take a single `Element`.
    typealias Observer = (Value) -> Void
    
    /// Adds a new observer.
    /// - parameter observer: The observer to be added.
    /// - returns: A `Subscription` instance.
    @discardableResult
    func observe(_ observer: @escaping Observer) -> Subscription
}

/// Represents a subscription to an observable type.
public protocol Subscription {
    /// Cancels the subscription.
    func unsubscribe()
}



public extension Observable {
    
    @discardableResult
    public func bind<R>(to object: R, keyPath: ReferenceWritableKeyPath<R, Value>) -> Subscription {
        return observe({ (value) in
            object[keyPath: keyPath] = value
        })
    }
    
}
