/// Conforming types can be converted to and from vector types.
///
/// This is the single requirement for any type that is to be animated
/// by `Animator`, `Simulator`, or `Spring`.
public protocol VectorConvertible: Equatable {
    
    /// The concrete VectorType implementation that can represent the 
    /// conforming type.
    associatedtype VectorType: SIMD where VectorType.Scalar == Double
    
    /// Creates a new instance from a vector.
    init(vector: VectorType)
    
    /// The vector representation of this instance.
    var vector: VectorType { get }
    
}

extension VectorConvertible {
    
    /// Returns an instance initialized using the zero vector.
    public static var zero: Self {
        return Self(vector: VectorType.zero)
    }
}

public typealias Vector2 = SIMD2<Double>
public typealias Vector3 = SIMD3<Double>
public typealias Vector4 = SIMD4<Double>


/// ********************************************************************************
/// VectorConvertible conformance extensions
/// ********************************************************************************

extension Double: VectorConvertible {

    public init(vector: Vector2) {
        self.init(vector.x)
    }
    
    public var vector: Vector2 {
        return Vector2(x: self, y: 0.0)
    }
    
}

extension Float: VectorConvertible {
    
    public init(vector: Vector2) {
        self.init(vector.x)
    }
    
    public var vector: Vector2 {
        return Vector2(x: Double(self), y: 0.0)
    }
    
}

#if canImport(UIKit)

import UIKit

extension UIOffset: VectorConvertible {
    
    public var vector: Vector2 {
        return Vector2(
            x: Double(horizontal),
            y: Double(vertical))
    }
    
    public init(vector: Vector2) {
        self.init(
            horizontal: CGFloat(vector.x),
            vertical: CGFloat(vector.y))
    }
    
}

extension UIEdgeInsets: VectorConvertible {
    
    public var vector: Vector4 {
        return Vector4(
            x: Double(top),
            y: Double(left),
            z: Double(bottom),
            w: Double(right))
    }
    
    public init(vector: Vector4) {
        self.init(
            top: CGFloat(vector.x),
            left: CGFloat(vector.y),
            bottom: CGFloat(vector.z),
            right: CGFloat(vector.w))
    }
    
}

#endif


#if canImport(CoreGraphics)

import CoreGraphics

extension CGSize: VectorConvertible {
    
    public init(vector: Vector2) {
        self.init(width: CGFloat(vector.x), height: CGFloat(vector.y))
    }
    
    public var vector: Vector2 {
        return Vector2(x: Double(width), y: Double(height))
    }
}

extension CGVector: VectorConvertible {
    
    public init(vector: Vector2) {
        self.init(dx: CGFloat(vector.x), dy: CGFloat(vector.y))
    }
    
    public var vector: Vector2 {
        return Vector2(x: Double(dx), y: Double(dy))
    }
}

extension CGPoint: VectorConvertible {
    
    public init(vector: Vector2) {
        self.init(
            x: CGFloat(vector.x),
            y: CGFloat(vector.y))
    }
    
    public var vector: Vector2 {
        return Vector2(
            x: Double(x),
            y: Double(y))
    }
}

extension CGFloat: VectorConvertible {
    
    public init(vector: Vector2) {
        self.init(vector.x)
    }
    
    public var vector: Vector2 {
        return Vector2(x: Double(self), y: 0.0)
    }
}

extension CGRect: VectorConvertible {
    
    public init(vector: Vector4) {
        self.init(
            x: CGFloat(vector.x),
            y: CGFloat(vector.y),
            width: CGFloat(vector.z),
            height: CGFloat(vector.w))
    }
    
    public var vector: Vector4 {
        return Vector4(
            x: Double(origin.x),
            y: Double(origin.y),
            z: Double(size.width),
            w: Double(size.height))
    }
}

#endif
