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

/// Conforming types can be converted to and from vector types.
public protocol VectorConvertible: Equatable, Interpolatable {
    
    /// The concrete VectorType implementation that can represent the 
    /// conforming type.
    associatedtype Vector: VectorType
    
    /// Creates a new instance from a vector.
    init(vector: Vector)
    
    /// The vector representation of this instance.
    var vector: Vector { get }
}

public extension VectorConvertible {
    
    /// Returns an instance initialized using the zero vector.
    public static var zero: Self {
        return Self(vector: Vector.zero)
    }
}

public extension VectorConvertible {
    
    /// Interpolates between values.
    ///
    /// - parameter to: The value to interpolate to.
    /// - parameter alpha: The amount (between 0.0 and 1.0) to interpolate,
    ///   where `0` returns the receiver, and `1` returns the `to` value.
    /// - Returns: The interpolated result.
    public func interpolatedTo(to: Self, alpha: Scalar) -> Self {
        return Self(vector: vector.interpolatedTo(to.vector, alpha: alpha))
    }
    
    /// Interpolates in place.
    ///
    /// - parameter to: The value to interpolate to.
    /// - parameter alpha: The amount (between 0.0 and 1.0) to interpolate,
    ///   where `0` leaves the receiver unchanged, and `1` assumes the value
    ///   of `to`.
    public mutating func interpolateTo(to: Self, alpha: Scalar) {
        self = interpolatedTo(to, alpha: alpha)
    }
    
}