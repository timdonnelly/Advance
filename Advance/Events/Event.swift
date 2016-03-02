/*

Copyright (c) 2016, Storehouse Media Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/// The state of the event.
public enum EventState<T> {
    
    /// The event is active and accepting new payloads.
    case Active
    
    /// The event is closed. Subsequent calls to `fire(payload:)` will be ignored.
    case Closed(T)
}

/// A simple EventType implementation.
public final class Event<T> {
    
    /// The current state of the event.
    private (set) public var state = EventState<T>.Active
    
    public typealias PayloadType = T
    public typealias Observer = (PayloadType) -> Void
    
    private var observers: [Observer] = []
    private var keyedObservers: [String:Observer] = [:]
    
    /// Returns `true` if the event state is `Closed`.
    public var closed: Bool {
        if case .Active = state {
            return false
        } else {
            return true
        }
    }
    
    private var closedValue: T? {
        if case let .Closed(v) = state {
            return v
        }
        return nil
    }
    
    /// Notifies observers.
    ///
    /// If the event has been closed, this has no effect.
    ///
    /// - parameter payload: A value to be passed to each observer.
    public func fire(payload: T) {
        guard closed == false else { return }
        deliver(payload)
    }
    
    /// Closes the event.
    ///
    /// If the event has already been closed, this has no effect.
    ///
    /// Calls all observers with the given payload. Once an event is closed,
    /// calling `fire(payload:)` or `close(payload:)` will have no effect.
    /// Adding an observer after an event is closed will simply call the
    /// observer synchronously with the payload that the event was closed
    /// with.
    public func close(payload: T) {
        guard closed == false else { return }
        state = .Closed(payload)
        deliver(payload)
    }
    
    private func deliver(payload: T) {
        for o in observers {
            o(payload)
        }
        for o in keyedObservers.values {
            o(payload)
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
    public func observe(observer: Observer) {
        guard closed == false else {
            observer(closedValue!)
            return
        }
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
    public func observe(observer: Observer, key: String) {
        guard closed == false else {
            observer(closedValue!)
            return
        }
        keyedObservers[key] = observer
    }
    
    /// Removed an observer with a given key.
    ///
    /// - seeAlso: func observe(observer:key:)
    /// - parameter key: A string that identifies the observer to be removed.
    ///   If an observer does not exist for the given key, the method returns
    ///   without impact.
    public func unobserve(key: String) {
        keyedObservers.removeValueForKey(key)
    }
}