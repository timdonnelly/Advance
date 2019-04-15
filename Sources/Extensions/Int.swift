extension Int: Interpolatable {
    
    public func interpolated(to otherValue: Int, alpha: Double) -> Int {
        let result = Double(self).interpolated(to: Double(otherValue), alpha: alpha)
        return Int(result)
    }
    
}
