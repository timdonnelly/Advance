[![Build Status](https://travis-ci.org/timdonnelly/Advance.svg?branch=master)](https://travis-ci.org/timdonnelly/Advance)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
![GitHub release](https://img.shields.io/github/release/timdonnelly/Advance.svg)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-orange.svg)](#swift-package-manager)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Advance.svg)](#cocoapods) 



# Advance

An animation library for iOS, tvOS, and macOS that uses physics-based animations (including springs) to power interactions that move and respond realistically.


```swift
let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

// Springs animate changes to a value
let spring = Spring(initialValue: view.center)

// The `onChange` closure will be called every time the spring updates
spring.onChange = { [view] newCenter in
    view.center = newCenter
}

/// The view's center will realistically animate to the new target value.
spring.target = CGPoint(x: 300, y: 200)
```

## Installation

There are several ways to integrate Advance into your project.

* **Manually:** add  `Advance.xcodeproj` to your project, then add `Advance-{iOS|macOS|tvOS}.framework` as an "Embedded Binary" to your application target (under General in target settings). From there, add `import Advance` to your code and you're good to go.

* **Carthage:** add `github "timdonnelly/Advance"` to your `Cartfile`.

* **CocoaPods:** add `pod 'Advance'` to your `Podfile`.

* **Swift Package Manager:** add a dependency to your `Project.swift`: `.package(url: "http://github.com/timdonnelly/Advance", from: "3.0.0")`

##### Requirements
* iOS 10+, tvOS 10+, or macOS 10.12+
* Swift 5.0 (Xcode 10.2 or higher)

## Usage

**API documentation is [available here](http://timdonnelly.github.io/Advance/).**

Advance animations are applied on every frame (using `CADisplayLink` on iOS/tvOS, and `CVDisplayLink` on macOS), allowing for fine-grained control at any time.


### `Spring`

`Spring` instances animate changes to a value over time, using spring physics.


```swift
let spring = Spring(initialValue: 0.0)
spring.onChange = { [view] newAlpha in 
    view.alpha = newAlpha 
}

// Off it goes!
spring.target = 0.5
```

#### Configuring a spring

```swift

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


### `Animator`

`Animator` allows for more flexibility in the types of animation that can be performed, but gives up some convenience
in order to do so. Specifically, animators allow for *any* type of animation or simulation to be performed for a single
value.

```swift
let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

/// Animators coordinate animations to drive changes to a value.
let sizeAnimator = Animator(initialValue: view.bounds.size)

sizeAnimator.onChange = { [view] newSize in
    view.bounds.size = newSize
}

/// A simple timed animation
sizeAnimator.animate(to: CGSize(width: 123, height: 456), duration: 0.25, timingFunction: .easeInOut)

/// Some time in the future (before the previous timed animation was complete)...

/// Spring physics will move the view's size to the new value, maintaining the velocity from the timed animation.
sizeAnimator.simulate(using: SpringFunction(target: CGSize(width: 300, height: 300)))

/// Some time in the future (before the previous spring animation was complete)...

/// The value will keep the same velocity that it had from the preceeding spring
/// animation, and a decay function will slowly bring movement to a stop.
sizeAnimator.simulate(using: DecayFunction(drag: 2.0))

```

Animators support two fundamentally different types of animations: timed and simulated.

#### Timed animations

Timed animations are, well, timed: they have a fixed duration, and they animate to a final value in a predictable manner.

```swift
animator.animate(to: CGSize(width: 123, height: 456), duration: 0.25, timingFunction: .easeInOut)
```

`TimingFunction` described the pacing of a timed animation. 

`TimingFunction` comes with a standard set of functions:

```swift
TimingFunction.linear // No easing
TimingFunction.easeIn
TimingFunction.easeOut
TimingFunction.easeInOut
TimingFunction.swiftOut // Similar to Material Design's default curve
```

Custom timing functions can be expressed as unit beziers ([described here](https://www.w3.org/TR/css-easing-1/#cubic-bzier-timing-function)).

```swift
let customTimingFunction = TimingFunction(x1: 0.1, y1: 0.2, x2: 0.6, y2: 0.0)
```

#### Simulated animations

Simulated animations use a *simulation function* to power a physics-based transition. Simulation functions are types conforming to the `SimulationFunction` protocol.

Simulated animations may be started using two different methods:

```swift
// Begins animating with the custom simulation function, maintaining the previous velocity of the animator.
animator.simulate(using: MyCustomFunction())

// or...

// Begins animating with the custom simulation function, imparting the specified velocity into the simulation.
animator.simulate(using: DecayFunction(), initialVelocity: dragGestureRecognizer.velocity(in: view))
```

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

If you encounter any issues or surprises, please open an issue.

For suggestions or new features, please consider opening a PR with a functional implementation. Issues may be used if you aren't sure how to implement the change, but working code is typically easier to evaluate.

## License
This project is released under the [BSD 2-clause license](https://github.com/timdonnelly/Advance/blob/master/LICENSE).
