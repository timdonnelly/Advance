public protocol KeyPathAnimatable: class {}

public extension KeyPathAnimatable {
    
    func animate<T>(keyPath: ReferenceWritableKeyPath<Self, T.Element>, with animation: T) -> Animator<T.Element> where T: Animation {
        return animation
            .run()
            .bound(to: self, keyPath: keyPath)
    }
    
}


#if os(iOS)

import UIKit

extension UIView: KeyPathAnimatable {}
extension CALayer: KeyPathAnimatable {}

#elseif os(macOS)

import AppKit

extension NSView: KeyPathAnimatable {}
extension CALayer: KeyPathAnimatable {}

#endif
