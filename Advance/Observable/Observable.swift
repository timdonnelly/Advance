import Foundation

public final class Observable<T> {
    
    public typealias Observer = (T) -> Void
    
    private var observers: [UUID:Observer] = [:]
    
    internal func send(value: T) {
        for o in observers.values {
            o(value)
        }
    }

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
