extension Bool: Interpolatable {
    
    public func interpolated(to otherValue: Bool, alpha: Scalar) -> Bool {
        switch (self, otherValue) {
        case (true, true):
            return true
        case (false, false):
            return false
        case (true, false):
            return alpha < 0.5
        case (false, true):
            return alpha >= 0.5
        }
    }
    
}
