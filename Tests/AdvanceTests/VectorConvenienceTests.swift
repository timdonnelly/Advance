import XCTest
@testable import Advance


class VectorConvenienceTests : XCTestCase {

    func testDoubleConversion() {
        let d = Double(12.0)
        let v = d.animatableData
        let d2 = Double(animatableData: v)
        XCTAssert(d == d2)
    }
    
    #if canImport(CoreGraphics)
    static var allTests = [
        ("testDoubleConversion", testDoubleConversion),
        ("testCGFloatConversion", testCGFloatConversion),
        ("testCGPointConversion", testCGPointConversion),
        ("testCGSizeConversion", testCGSizeConversion),
        ("testCGRectConversion", testCGRectConversion),
    ]
    #else
    static var allTests = [
        ("testDoubleConversion", testDoubleConversion),
    ]
    #endif
}

#if canImport(CoreGraphics)

import CoreGraphics

extension VectorConvenienceTests {
    func testCGFloatConversion() {
        let f = CGFloat(12.0)
        let v = f.animatableData
        let f2 = CGFloat(animatableData: v)
        XCTAssert(f == f2)
    }
    
    
    func testCGPointConversion() {
        let p = CGPoint(x: 12.0, y: 60.0)
        let v = p.animatableData
        let p2 = CGPoint(animatableData: v)
        XCTAssert(p == p2)
    }
    
    func testCGSizeConversion() {
        let s = CGSize(width: 12.0, height: 60.0)
        let v = s.animatableData
        let s2 = CGSize(animatableData: v)
        XCTAssert(s == s2)
    }
    
    func testCGRectConversion() {
        let r = CGRect(x: 12.0, y: 60.0, width: 100.0, height: 3.0)
        let v = r.animatableData
        let r2 = CGRect(animatableData: v)
        XCTAssert(r == r2)
    }
    
}

#endif
