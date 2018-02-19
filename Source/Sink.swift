import Foundation


internal final class Sink<T>: Observable {
    
    typealias Observer = (T) -> Void
    
    private var observers: [UUID:Observer] = [:]
    
    func send(value: T) {
        for o in observers.values {
            o(value)
        }
    }
    
    @discardableResult
    func observe(_ observer: @escaping Observer) -> Subscription {
        let identifier = UUID()
        observers[identifier] = observer
        
        let subscription = _Subscription { [weak self] in
            self?.removeObserver(for: identifier)
        }
        
        return subscription
    }
    
    private func removeObserver(for identifier: UUID) {
        observers.removeValue(forKey: identifier)
    }
    
}

fileprivate extension Sink {
    
    /// Represents a subscription to an `Observable`.
    final class _Subscription: Subscription {
        
        private var hasUnsubscribed: Bool
        private let unsubscribeAction: () -> Void
        
        init(unsubscribeAction: @escaping () -> Void) {
            self.hasUnsubscribed = false
            self.unsubscribeAction = unsubscribeAction
        }
        
        func unsubscribe() {
            guard !hasUnsubscribed else { return }
            hasUnsubscribed = true
            unsubscribeAction()
        }
    }
}


