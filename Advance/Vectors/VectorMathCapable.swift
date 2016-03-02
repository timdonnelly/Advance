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

import Foundation
import simd

/// Conforming types implement functions for basic vector arithmetic.
public protocol VectorMathCapable {
    /// Product.
    func *(lhs: Self, rhs: Self) -> Self
    
    /// Product (in place).
    func *=(inout lhs: Self, rhs: Self)
    
    /// Quotient.
    func /(lhs: Self, rhs: Self) -> Self
    
    /// Quotient (in place).
    func /=(inout lhs: Self, rhs: Self)
    
    /// Sum.
    func +(lhs: Self, rhs: Self) -> Self
    
    /// Sum (in place).
    func +=(inout lhs: Self, rhs: Self)
    
    /// Difference.
    func -(lhs: Self, rhs: Self) -> Self
    
    /// Difference (in place).
    func -=(inout lhs: Self, rhs: Self)
    
    /// Scalar-Vector product.
    func *(lhs: Scalar, rhs: Self) -> Self
}