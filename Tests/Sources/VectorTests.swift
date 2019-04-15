import XCTest
@testable import Advance


class VectorTests: XCTestCase {
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


struct VectorTester<T: Vector> {
    static func runTests() {
        testZero()
        testEquatable()
        testClamp()
        testInterpolatable()
        testMath()
    }
    
    
    static func testZero() {
        XCTAssert(T(Double: 0.0) == T.zero)
    }
    
    static func testEquatable() {
        let v1 = T(Double: 123.0)
        let v2 = T(Double: 123.0)
        let v3 = T(Double: 10.0)
        XCTAssert(v1 == v2)
        XCTAssert(v1 != v3)
    }
    
    static func testClamp() {
        let min = T(Double: -10.0)
        let max = T(Double: 20.0)
        
        let v1 = T(Double: -20.0)
        let v2 = T(Double: 30.0)
        let v3 = T(Double: 15.0)
        
        XCTAssert(v1.clamped(min: min, max: max) == min)
        XCTAssert(v2.clamped(min: min, max: max) == max)
        XCTAssert(v3.clamped(min: min, max: max) == v3)
    }
    
    static func testInterpolatable() {
        let v1 = T(Double: 0.0)
        let v2 = T(Double: 10.0)
        XCTAssert(v1.interpolated(to: v2, alpha: 0.0) == v1)
        XCTAssert(v1.interpolated(to: v2, alpha: 0.55) == T(Double: 5.5))
        XCTAssert(v1.interpolated(to: v2, alpha: 1.0) == v2)
    }
    
    static func testMath() {
        let s1 = Double(9.0)
        let s2 = Double(17.3)
        let v1 = T(Double: s1)
        let v2 = T(Double: s2)
        
        XCTAssert(v1 + v2 == T(Double: s1 + s2))
        XCTAssert(v1 - v2 == T(Double: s1 - s2))
        XCTAssert(v1 * v2 == T(Double: s1 * s2))
        XCTAssert(v1 / v2 == T(Double: s1 / s2))
        
        XCTAssert(Double(2.0) * v2 == T(Double: 2.0 * s2))
        
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
