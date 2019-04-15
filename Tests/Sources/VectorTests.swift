import XCTest
@testable import Advance


class VectorTests: XCTestCase {
    func testVector1() {
        XCTAssert(Vector1.scalarCount == 1)
        VectorTester<Vector1>.runTests()
    }
    
    func testVector2() {
        XCTAssert(Vector2.scalarCount == 2)
        VectorTester<Vector2>.runTests()
    }
    
    func testVector3() {
        XCTAssert(Vector3.scalarCount == 3)
        VectorTester<Vector3>.runTests()
    }
    
    func testVector4() {
        XCTAssert(Vector4.scalarCount == 4)
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
        XCTAssert(T(repeating: 0.0) == T.zero)
    }
    
    static func testEquatable() {
        let v1 = T(repeating: 123.0)
        let v2 = T(repeating: 123.0)
        let v3 = T(repeating: 10.0)
        XCTAssert(v1 == v2)
        XCTAssert(v1 != v3)
    }
    
    static func testClamp() {
        let min = T(repeating: -10.0)
        let max = T(repeating: 20.0)
        
        let v1 = T(repeating: -20.0)
        let v2 = T(repeating: 30.0)
        let v3 = T(repeating: 15.0)
        
        XCTAssert(v1.clamped(min: min, max: max) == min)
        XCTAssert(v2.clamped(min: min, max: max) == max)
        XCTAssert(v3.clamped(min: min, max: max) == v3)
    }
    
    static func testInterpolatable() {
        let v1 = T(repeating: 0.0)
        let v2 = T(repeating: 10.0)
        XCTAssert(v1.interpolated(to: v2, alpha: 0.0) == v1)
        XCTAssert(v1.interpolated(to: v2, alpha: 0.55) == T(repeating: 5.5))
        XCTAssert(v1.interpolated(to: v2, alpha: 1.0) == v2)
    }
    
    static func testMath() {
        let s1 = Double(9.0)
        let s2 = Double(17.3)
        let v1 = T(repeating: s1)
        let v2 = T(repeating: s2)
        
        XCTAssert(v1 + v2 == T(repeating: s1 + s2))
        XCTAssert(v1 - v2 == T(repeating: s1 - s2))
        XCTAssert(v1 * v2 == T(repeating: s1 * s2))
        XCTAssert(v1 / v2 == T(repeating: s1 / s2))
        
        XCTAssert(Double(2.0) * v2 == T(repeating: 2.0 * s2))
        
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
