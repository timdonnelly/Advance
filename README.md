# Advance

Physics-based animations for iOS, tvOS, and macOS.

This project was originally developed to power the animations throughout the Storehouse app for iOS, but has since been extensively rewritten in modern Swift.

## What's new in 2.0?

Nearly everything. Pre-2.0 was largely an Objective-C port, so 2.0 was a chance to clean up and rethink the external API.

The API is much smaller as a result, providing a handful of types that make it easy to integrate physics-based animations.

## Examples

#### `Spring`

```swift
import Advance

let spring = Spring(value: CGPoint.zero)
spring.bind(to: view, keyPath: \.center)
spring.target = CGPoint(x: 300, y: 200)

```
The spring will then animate the movement of the view to the new `target` position.

`Spring` is the simplest way to introduce physics-based animations, providing full access to the underlying spring simulation (target, tension, damping, velocity, etc) at any time: even while the simulation is in progress.

#### `PropertyAnimator`

```swift
import Advance

let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

let sizeAnimator = PropertyAnimator(target: view, keyPath: \.bounds.size)

/// Spring physics will move the view's size to the new value.
sizeAnimator.spring(to: CGSize(width: 300, height: 300))

/// Some time in the future...

/// The value will keep the same velocity that it had from the preceeding
/// animation, and a decay function will slowly bring movement to a stop.
sizeAnimator.decay(drag: 2.0)

```

`PropertyAnimator` is the most flexible way to apply multiple types of animations to an object.

If you don't need direct access to a running simulation and want the flexibility of using various animation types for the same value, `PropertyAnimator` is your best bet.


#### Check out the sample app

![Sample app](https://github.com/timdonnelly/Advance/raw/master/images/nav.gif)
![Sample app](https://github.com/timdonnelly/Advance/raw/master/images/logo.gif)

****

## Core Concepts

Three primary classes are used to power animations in your UI.

#### `PropertyAnimator`

The easiest way to use Advance is with the `PropertyAnimator` class. This class manages animations for a specific property of a target object.

```
let view = UIView()
let boundsAnimator = PropertyAnimator(target: view, keyPath: \.bounds)
```

#### `Simulator` / `Spring`

In most scenarios, physics-based animations are simply run to completion. For those situations, `Animator` and `PropertyAnimator` make it easy to run and use the results of an animation.

In contrast, `Simulator` is useful for scenarios where you need direct access to a running simulation. This might occur in a UI where the user's scroll position drives changes to a spring's tension, for example. It would be impractical to create and start a new animation every time the simulation needs to change. A `Simulator` instance provides mutable access to the `function` property (containing the underlying function that is driving the simulation), along with the current state of the simulation (value and velocity).

`Simulator` conforms to `Observable`, so you can easily be notified when the simulated value changes.

**Spring** is a specialized simulator that uses a spring function. If all you are after is a simple spring to animate a value, this is what you want.

```

let spring = Spring(value: 0.0)
simulator.observe { nextValue in
    /// Do something with the spring's v
}

spring.target = 120.0

```

### Animations


There are two primary types of animations in Advance: **Simulated Animations** and **Basic Animations**.

**Basic animations** are conventional animations similar to those seen in most animation libraries: they have a duration and timing function which are used to interpolate between a start and end value as the animation progresses.

**Simulated animations** use a physics-based approach to model changes to a value over time. This allows for realistic animations that model real-world behavior.

Simulated animations are powered by a **Simulation Function**. These functions compute the forces that should effect the animated value for every frame, and control *convergence* (or: when the simulation should come to rest). The included simulation functions are:
- Spring
- Decay
- Gravity


## Contributing

**The best contribution you can provide is feedback.** This library was designed in the context of a specific product – I'd love to hear more about your project and how Advance can be improved to meet your needs.

*(Of course, pull requests are always welcome)*

## Usage

There are several ways to integrate Advance into your project.

* Manually, as a framework: simply add the `Advance.xcodeproj` to your project and add `Advance.framework` as an "Embedded Binary" to your application target (under General in target settings). From there, add `import Advance` to your code and you're good to go.

* Carthage: add `github "timdonnelly/Advance" "master"` to your `Cartfile`.

* CocoaPods: add `pod 'Advance', '~> 2.0'` to your `Podfile`.

##### Requirements
* iOS 10+, tvOS 10+, or macOS 10.12+
* Swift 4.0+ (Xcode 9 or higher)

## Documentation
API documentation is [available here](http://timdonnelly.github.io/Advance/).

## License
This project is released under the [BSD 2-clause license](https://github.com/timdonnelly/Advance/blob/master/LICENSE).
