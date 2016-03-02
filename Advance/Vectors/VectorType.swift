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

/// The underlying type of scalar quantities.
public typealias Scalar = Double

/// Conforming types can be operated on as vectors composed of `Scalar` components.
public protocol VectorType: Equatable, Interpolatable, VectorMathCapable {
    
    /// Creates a vector for which all components are equal to the given scalar.
    init(scalar: Scalar)
    
    /// The number of scalar components in this vector type.
    static var length: Int { get }
    
    /// The empty vector (all scalar components are equal to `0.0`).
    static var zero: Self { get }
    
    /// Subscripting for vector components.
    subscript(index: Int) -> Scalar { get set }
    
    /// Returns a vector where each component is clamped by the corresponding
    /// components in `min` and `max`.
    ///
    /// - parameter x: The vector to be clamped.
    /// - parameter min: Each component in the output vector will `>=` the
    ///   corresponding component in this vector.
    /// - parameter max: Each component in the output vector will be `<=` the
    ///   corresponding component in this vector.
    func clamped(min min: Self, max: Self) -> Self
    
    /// Clamps in place.
    mutating func clamp(min: Self, max: Self)
}


public extension VectorType {
    
    /// Returns a vector where each component is clamped by the corresponding
    /// components in `min` and `max`.
    public func clamped(min min: Self, max: Self) -> Self {
        var result = self
        for i in 0..<Self.length {
            if result[i] < min[i] { result[i] = min[i] }
            if result[i] > max[i] { result[i] = max[i] }
        }
        return result
    }
    
    /// Clamps in place.
    public mutating func clamp(min: Self, max: Self) {
        self = clamped(min: min, max: max)
    }
}