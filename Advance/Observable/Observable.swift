import Foundation

/// A simple EventType implementation.
public final class Observable<T> {
    
    public typealias Observer = (T) -> Void
    
    private var observers: [UUID:Observer] = [:]
    
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
    /// - parameter observer: A closure that will be executed when this event
    ///   is fired.
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
    
    struct Subscription {
        
        private let _unsubscribe: () -> Void
        
        fileprivate init(unsubscribeAction: @escaping () -> Void) {
            _unsubscribe = unsubscribeAction
        }
        
        public func unsubscribe() {
            _unsubscribe()
        }
    }
    
}

internal final class Sink<T> {
    
    let observable = Observable<T>()
    
    func send(value: T) {
        observable.send(value: value)
    }
    
}
