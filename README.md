<br/><img src="https://github.com/storehouse/Advance/raw/master/Assets/logo.png" width="302">

A powerful animation framework for iOS, tvOS, and OS X.

---

##### What is it?
Advance is a pure Swift framework that enables advanced animations and physics-based interactions.

Originally developed to power the animations throughout the Storehouse app for iOS, Advance has evolved into a composable set of tools with a [simple API](http://storehouse.github.io/Advance/docs). It uses a `CADisplayLink` instance to drive animations and simulations that advance on each frame.

##### Should I use it?
Advance shines when:

* You are building gesture-based interactions that use physics to reflect the behavior of the real world.
* You need to animate custom types with per-frame callbacks.
* ???. Advance is extensible, making it easy to build custom animation and simulation types.

You can accomplish amazing things with Advance. But you should be sensitive to the performance impact of performing per-frame animations on the main thread. Check out [this article](https://www.objc.io/issues/12-animations/interactive-animations/) on objc.io for a good overview.

*If you simply want to animate the basic properties of a view, it's probably best to stick with UIView animations / Core Animation. It is able to run your animations on a high priority background thread and is not as sensitive to blocking the main thread.*

##### Requirements
* iOS 8+, tvOS 9+, or OS X 10.10+
* Swift 2.2+


### Examples

##### Check out the sample app.
Located in the project:

![Sample app](https://github.com/storehouse/Advance/raw/master/Assets/nav.gif)
![Sample app](https://github.com/storehouse/Advance/raw/master/Assets/logo.gif)

****

##### Animate between two numbers.

```swift
import Advance

0.0.animateTo(3.0, duration: 2.0, timingFunction: LinearTimingFunction()) { (value) in
    print("value: \(value)")
    // Do something with value
}
```
This will create and run an animation from `0.0` to `3.0`, calling the closure at each step of the animation.

****

##### Use `Animatable` to contain values that can be animated with any animation type.

```swift
import Advance

class MyClass {

  let center: Animatable<CGPoint>

  init() {
    ...
    center.changed.observe { (value) in
      // Do something every time the center value changes
    }
  }
}

let foo = MyClass()

// foo.center.animateTo(...)
// foo.center.springTo(...)
// foo.center.decay(...)
// foo.center.animate(<custom animation type>)
```

****

##### Use `Spring` to contain values that will only be driven by spring physics.

Instances of `Spring` should be used in situations where spring physics are the only animation type required, or when convenient access to the properties of a running spring simulation is needed.

The focused API of this class makes it more convenient in such cases than using an `Animatable` instance, where a new spring animation would have to be added each time the spring needed to be modified.

The `Spring` class also serves as an example of how some of the internal components of the framework can be composed to build new components.

```swift
import Advance

let s = Spring(value: CGPoint.zero)

s.changed.observe { (value) in
  // do something with the value when it changes
}

s.target = CGPoint(x: 100.0, y: 200.0)
// The spring will begin moving to the new value

// Some time in the future...

s.target = CGPoint.zero
// The value will come back to zero.
```

### Animatable types

Any type conforming to `VectorConvertible` can be animated. 

```swift
public protocol VectorConvertible: Equatable, Interpolatable {
    typealias Vector: VectorType
    init(vector: Vector)
    var vector: Vector { get }
}
```

`VectorConvertible` is a simple protocol that allows instances of the the conforming type to:

* Define an associated type called `Vector`, which must be a concrete implementation of `VectorType`. Implementations of 1, 2, 3, and 4 component vectors are provided.
* Be initialized with a `Vector` instance.
* Provide a `Vector` representation of itself.

The associated type `Vector` is a concrete implementation of `VectorType`. For example, `CGSize` defines the associated type as `Vector2` (a two component vector, as size has a width and a height component):

```swift
extension CGSize: VectorConvertible {
    
    /// The underlying vector type.
    public typealias Vector = Vector2
    
    /// Creates a new instance from a vector.
    public init(vector: Vector) {
        self.init(width: CGFloat(vector.x), height: CGFloat(vector.y))
    }
    
    /// Returns the vector representation.
    public var vector: Vector {
        return Vector(Scalar(width), Scalar(height))
    }
}
```

Extensions are provided to add `VectorConvertible` conformance to many of the types used in the UI layer. Animating custom types is as easy as adding an extension similar to the example above.

### Design

Advance embraces composition and value types throughout.

There are a few foundational types at the core of the Advance framework:


##### `Advanceable` protocol
Conforming types can be advanced on each frame by a given duration.

```swift
public protocol Advanceable {
    mutating func advance(elapsed: Double)
}
```

`Advanceable` is the mechanism by which all animations are performed. A typical device updates the screen 60 times per second – this means each frame has a duration of 0.016 seconds (1/60).

##### `AnimationType` protocol
Inherits from `Advanceable`. 

```swift
public protocol AnimationType: Advanceable {
    var finished: Bool { get }
}
```

Animations have a finite length (defined by each implementation). When the animation is complete, it returns `true` for the `finished` property.

##### `ValueAnimationType` protocol
Inherits from `AnimationType`.

```swift
public protocol ValueAnimationType: AnimationType {
    typealias Value: VectorConvertible
    var value: Value { get }
    var velocity: Value { get }
}
```

Types conforming to `ValueAnimationType` can be used to animate values of any type conforming to `VectorConvertible`, as they support querying for the current value and velocity on each frame.

The framework includes the following animations:

* `BasicAnimation` uses a specified timing function and duration.
* `SpringAnimation` uses a `DynamicSolver`/`SpringFunction` internally to animate to the final value.
* `DecayAnimation` uses a `DynamicSolver`/`DecayFunction` internally to animate to the final value.



****

[Please see the documentation](http://storehouse.github.io/Advance/docs) and check out the sample app (AdvanceSample) in the project for more details.

### Notes

##### Performance

Advance uses Swift generics extensively. This has many benefits, including the ability to natively animate nearly any value type without casting (or using `NSValue` wrappers, etc).

The Swift compiler can heavily optimize generics through the process of *specialization* – in which it generates specific implementations of generic functions based on the way your code calls them. Unfortunately, specialization cannot occur between modules. This means that the compiler will be unable to fully optimize when Advance is built as a framework.

**This probably does not matter in your application**. Even with the small amount of overhead required to call generic functions, modern CPUs are fast; running a few animations will have little impact. If your application has many simultaneous animations, however, and you are looking for ways to optimize, you may see an improvement by bringing in all of the .swift files and compiling Advance as part of your project.

##### Thread safety

Advance classes are **not** thread safe, and expect to be used from the main thread only.

With that said, the majority of the framework is implemented as a set of protocols and value types. Because value semantics are implicitly safe to pass between threads, you can safely accomplish many things asynchronously. You just need to be sure that classes such as `Animator`, `Animatable`, and `Spring` are accessed from the main thread only.

### Status
- **Tests:** More tests are needed. Test coverage is provided for some of the core types, but it is not yet comprehensive enough.

- **Documentation:** Nearly every type is briefly commented, but expanding the documentation to include discussion and examples where appropriate is a goal of the project.

- **API Stability** I currently consider the API to be in draft form (thus the < 1.0 version of the project).

*Suggestions / pull requests / etc are welcome!*

### Usage

There are several ways to integrate Advance into your project.

* Manually, as a framework: simply add the `Advance.xcodeproj` to your project and add `Advance.framework` as an "Embedded Binary" to your application target (under General in target settings). From there, add `import Advance` to your code and you're good to go.

* Swift Package Manager (experimental).

* Carthage: add `github "storehouse/Advance" "master"` to your `Cartfile`.

* CocoaPods: add `pod 'Advance', '~> 0.9'` to your `Podfile`.

### Documentation
API documentation is [available here](http://storehouse.github.io/Advance/docs).

### License
This project is released under the [BSD 2-clause license](https://github.com/storehouse/Advance/blob/master/LICENSE).
