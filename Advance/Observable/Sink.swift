internal final class Sink<T> {
    
    let observable = Observable<T>()
    
    func send(value: T) {
        observable.send(value: value)
    }
    
}
