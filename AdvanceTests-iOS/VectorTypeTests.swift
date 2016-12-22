import XCTest
@testable import Advance


class VectorTypeTests: XCTestCase {
    func testVector1() {
        XCTAssert(Vector1.length == 1)
        VectorTester<Vector1>.runTests()
    }
    
    func testVector2() {
        XCTAssert(Vector2.length == 2)
        VectorTester<Vector2>.runTests()
    }
    
    func testVector3() {
        XCTAssert(Vector3.length == 3)
        VectorTester<Vector3>.runTests()
    }
    
    func testVector4() {
        XCTAssert(Vector4.length == 4)
        VectorTester<Vector4>.runTests()
    }
}


struct VectorTester<T: VectorType> {
    static func runTests() {
        testScalarInit()
        testZero()
        testSubscripting()
        testEquatable()
        testClamp()
        testInterpolatable()
        testMath()
    }
    
    static func testScalarInit() {
        let v = T(scalar: 5.2)
        for i in 0..<T.length {
            XCTAssert(v[i] == 5.2)
        }
    }
    
    static func testZero() {
        XCTAssert(T(scalar: 0.0) == T.zero)
    }
    
    static func testSubscripting() {
        var v = T.zero
        for i in 0..<T.length {
            v[i] = Scalar(i)
        }
        for i in 0..<T.length {
            XCTAssert(v[i] == Scalar(i))
        }
    }
    
    static func testEquatable() {
        let v1 = T(scalar: 123.0)
        let v2 = T(scalar: 123.0)
        let v3 = T(scalar: 10.0)
        XCTAssert(v1 == v2)
        XCTAssert(v1 != v3)
    }
    
    static func testClamp() {
        let min = T(scalar: -10.0)
        let max = T(scalar: 20.0)
        
        let v1 = T(scalar: -20.0)
        let v2 = T(scalar: 30.0)
        let v3 = T(scalar: 15.0)
        
        XCTAssert(v1.clamped(min: min, max: max) == min)
        XCTAssert(v2.clamped(min: min, max: max) == max)
        XCTAssert(v3.clamped(min: min, max: max) == v3)
    }
    
    static func testInterpolatable() {
        let v1 = T(scalar: 0.0)
        let v2 = T(scalar: 10.0)
        XCTAssert(v1.interpolatedTo(v2, alpha: 0.0) == v1)
        XCTAssert(v1.interpolatedTo(v2, alpha: 0.55) == T(scalar: 5.5))
        XCTAssert(v1.interpolatedTo(v2, alpha: 1.0) == v2)
    }
    
    static func testMath() {
        let s1 = Scalar(9.0)
        let s2 = Scalar(17.3)
        let v1 = T(scalar: s1)
        let v2 = T(scalar: s2)
        
        XCTAssert(v1 + v2 == T(scalar: s1 + s2))
        XCTAssert(v1 - v2 == T(scalar: s1 - s2))
        XCTAssert(v1 * v2 == T(scalar: s1 * s2))
        XCTAssert(v1 / v2 == T(scalar: s1 / s2))
        
        XCTAssert(Scalar(2.0) * v2 == T(scalar: 2.0 * s2))
        
        func testInPlaceMath(_ function: (inout T, T) -> Void, expectedValue: T) {
            var m = v1
            function(&m, v2)
            XCTAssert(m == expectedValue)
        }
        
        testInPlaceMath(+=, expectedValue: v1 + v2)
        testInPlaceMath(-=, expectedValue: v1 - v2)
        testInPlaceMath(*=, expectedValue: v1 * v2)
        testInPlaceMath(/=, expectedValue: v1 / v2)
    }
}
