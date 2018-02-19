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
        
        let subscription = Subscription { [weak self] in
            self?.removeObserver(for: identifier)
        }
        
        return subscription
    }
    
    private func removeObserver(for identifier: UUID) {
        observers.removeValue(forKey: identifier)
    }
    
}

public extension Observable {
    
    /// Represents a subscription to an `Observable`.
    struct Subscription {
        
        private let _unsubscribe: () -> Void
        
        fileprivate init(unsubscribeAction: @escaping () -> Void) {
            _unsubscribe = unsubscribeAction
        }
        
        /// Cancels the subscription.
        public func unsubscribe() {
            _unsubscribe()
        }
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
