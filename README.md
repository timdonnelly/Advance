# Advance

Physics-based animations for iOS, tvOS, and macOS.

## Usage

In contrast to standard `UIView` animations, Advance animations are applied on every frame (using `CADisplayLink` on iOS).


```swift
let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

/// Springs are... springs. That's all they do.
let spring = Spring(initialValue: view.center)

spring.onChange = { [view] newCenter in
    view.center = newCenter
}

/// The view's center will realistically animate to the new value.
spring.target = CGPoint(x: 300, y: 200)
```


## Spring

`Spring` covers the common case in which a value should be driven by spring physics. It implements a specific
`Simulator` subclass (using a `SpringFunction`) that provides convenient API when working with a spring.

Convenience extensions provide full access to the underlying spring simulation (target, tension, damping, velocity, etc) at any time: even while the simulation is in progress.


```swift
let spring = Spring(initialValue: 0.0)
spring.onChange = { [view] newAlpha in view.alpha = newAlpha }
spring.target = 0.5

/// Spring values can be adjusted at any time.
spring.tension = 30.0 /// The strength of the spring
spring.damping = 2.0 /// The resistance (drag) that the spring encounters
spring.threshold = 0.1 /// The maximum delta between the current value and the spring's target (for each component) for which the simulation can enter a converged state.

/// Update the simulation state at any time.
spring.velocity = 6.5
spring.value = 0.2

/// Sets the spring's target and the current simulation value, and removes all velocity. This causes the spring to converge at the given value.
spring.reset(to: 0.5)

```

## Simulator

`Simulator` uses a physics-based simulation to realistically model changes to a value over time. It is the superclass of `Spring`, and may be used to power any `SimulationFunction` implementation, inclusing custom types.

A `Simulator` instance provides mutable access to the `function` property (containing the underlying function that is driving the simulation), along with the current state of the simulation (value and velocity).

Simulations are powered by a **Simulation Function**. These functions compute the forces that should effect the value for every frame, and control *convergence* (or: when the simulation should come to rest). The included simulation functions are:
- `SpringFunction`
- `DecayFunction`

```swift
let function = DecayFunction(drag: 20.0)
let simulator = Simulator(function: function, initialValue: CGPoint.zero)
simulator.onChange = { value in
    /// Apply the new value.
}

simulator.velocity = CGPoint(x: 100, y: 100)
```

## Animator

`Animator` allows for more flexibility in the types of animation that can be performed, but gives up some convenience
in order to do so. Specifically, animators allow for *any* type of animation or simulation to be performed for a single
animator, but they do not allow access to the underlying physics state.

```swift
let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

/// Animators coordinate animations to drive changes to a value.
let sizeAnimator = Animator(initialValue: view.bounds.size)

sizeAnimator.onChange = { [view] newSize in
    view.bounds.size = newSize
}

/// Spring physics will move the view's size to the new value.
sizeAnimator.spring(to: CGSize(width: 300, height: 300))

/// Some time in the future...

/// The value will keep the same velocity that it had from the preceeding
/// animation, and a decay function will slowly bring movement to a stop.
sizeAnimator.decay(drag: 2.0)

/// or...

sizeAnimator.spring(to: CGSize(width: 100, height: 500))

```

##### Timing Functions

Basic animations use a timing function to control the pacing of the value's change over the course of the animation. Timing functions are types conforming to the `TimingFunction` protocol. Advance includes the following timing function implementations.

- `LinearTimingFunction` 
- `UnitBezier`
- `CAMediaTimingFunction` (`TimingFunction` conformance via an extension)




### Animating Custom Types

Values conforming to the `VectorConvertible` protocol can be animated by Advance. Conforming types can be converted to and from a `Vector` implementation.
```swift
public protocol VectorConvertible: Equatable, Interpolatable {
    associatedtype VectorType: SIMD where VectorType.Scalar == Double
    init(vector: VectorType)
    var vector: VectorType { get }
}
```

The library adds conformance for many common types through extensions.


## Contributing

**The best contribution you can provide is feedback.** This library was designed in the context of a specific product – I'd love to hear more about your project and how Advance can be improved to meet your needs.

*(Of course, pull requests are always welcome)*

## Usage

There are several ways to integrate Advance into your project.

* Manually, as a framework: simply add the `Advance.xcodeproj` to your project and add `Advance-{iOS|macOS|tvOS}.framework` as an "Embedded Binary" to your application target (under General in target settings). From there, add `import Advance` to your code and you're good to go.

* Carthage: add `github "timdonnelly/Advance"` to your `Cartfile`.

* CocoaPods: add `pod 'Advance'` to your `Podfile`.

##### Requirements
* iOS 10+, tvOS 10+, or macOS 10.12+
* Swift 5.0 (Xcode 10.2 or higher)

## Documentation
API documentation is [available here](http://timdonnelly.github.io/Advance/).

## License
This project is released under the [BSD 2-clause license](https://github.com/timdonnelly/Advance/blob/master/LICENSE).
