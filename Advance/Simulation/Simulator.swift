
public final class Simulator<T> where T: Simulation {
    
    private let changedSink = Sink<T>()
    
    private var simulation: T {
        didSet {
            subscription.paused = simulation.isSettled
        }
    }
    
    private let subscription: Loop.Subscription
    
    public var current: Observable<T> {
        return changedSink.observable
    }
    
    /// Creates a new `Simulator` instance
    ///
    /// - parameter simulation: The simulation type that will be driven by this
    ///   simulator instance.
    public init(simulation: T) {
        self.simulation = simulation
        self.subscription = Loop.shared.subscribe()
        
        subscription.paused = simulation.isSettled
    }
    
    private func advance(by time: Double) {
        simulation.advance(by: time)
        if simulation.isSettled {
            subscription.paused = true
        }
    }
    
}

