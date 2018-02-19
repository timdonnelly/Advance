import Foundation



/// Represents a changing stream of values that can be observed.
public final class Observable<T> {
    
    public typealias Observer = (T) -> Void
    
    private var observers: [UUID:Observer] = [:]
    
    internal func send(value: T) {
        for o in observers.values {
            o(value)
        }
    }

    /// Adds a new observer.
    /// - parameter observer: The observer to be added.
    /// - returns: A `Subscription` instance.
    @discardableResult
    public func observe(_ observer: @escaping Observer) -> Subscription {
        let identifier = UUID()
        observers[identifier] = observer
        
        let subscription = AnySubscription { [weak self] in
            self?.removeObserver(for: identifier)
        }
        
        return subscription
    }
    
    private func removeObserver(for identifier: UUID) {
        observers.removeValue(forKey: identifier)
    }
    
}

public extension Observable {
    

    
}

/// Represents a subscription to an observable type.
public protocol Subscription {
    /// Cancels the subscription.
    func unsubscribe()
}

/// Represents a subscription to an `Observable`.
final class AnySubscription: Subscription {
    
    private var hasUnsubscribed: Bool
    private let unsubscribeAction: () -> Void
    
    fileprivate init(unsubscribeAction: @escaping () -> Void) {
        self.hasUnsubscribed = false
        self.unsubscribeAction = unsubscribeAction
    }
    
    public func unsubscribe() {
        guard !hasUnsubscribed else { return }
        hasUnsubscribed = true
        unsubscribeAction()
    }
}

public extension Observable {
    
    @discardableResult
    public func bind<R>(to object: R, keyPath: ReferenceWritableKeyPath<R, T>) -> Subscription {
        return observe({ (value) in
            object[keyPath: keyPath] = value
        })
    }
    
}
