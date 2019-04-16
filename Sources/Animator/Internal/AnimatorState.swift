extension Animator {
    
    enum State {
        case atRest(value: Value)
        case animating(animation: AnyAnimation<Value>)
        
        
        mutating func advance(by time: Double) {
            switch self {
            case .atRest: break
            case .animating(var animation):
                animation.advance(by: time)
                if animation.isFinished {
                    self = .atRest(value: animation.value)
                } else {
                    self = .animating(animation: animation)
                }
            }
        }
        
        
        var isAtRest: Bool {
            switch self {
            case .atRest: return true
            case .animating: return false
            }
        }
        
        var value: Value {
            switch self {
            case .atRest(let value): return value
            case .animating(let animation): return animation.value
            }
        }
        
        var velocity: Value {
            switch self {
            case .atRest(_): return .zero
            case .animating(let animation): return animation.velocity
            }
        }
        
    }
    
}
