# Advance

Physics-based animations for iOS, tvOS, and macOS.

---

## What is it?

Advance enables fully interactive and interruptable physics-based animations.

This project was originally developed to power the animations throughout the Apple Design Award winning Storehouse app for iOS, but has since been extensively rewritten in modern Swift.

## Examples

#### Use a `Spring` to animate the position of a view

```swift
import Advance

let spring = Spring(value: CGPoint.zero)
spring.bind(to: view, keyPath: \.center)
spring.target = CGPoint(x: 300, y: 200)

```
The spring will then animate the movement of the view to the new `target` position.

#### Use `PropertyAnimator` to animate an object's properties

```swift
import Advance

let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

let centerAnimator = PropertyAnimator(target: view, keyPath: \.center)

/// Spring physics will move the view's center to the new value.
centerAnimator.spring(to: CGPoint(x: 300, y: 300))

/// Some time in the future...

/// The value will keep the same velocity that it had from the preceeding
/// animation, and a decay function will slowly bring movement to a stop.
centerAnimator.decay(drag: 2.0)

```


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

#### `Animator`

This class is used to drive a single animation to completion. It is one-shot, so an animator is no longer useful after the animation that it is driving completes.

```swift
import Advance

let animation = 0.0.animation(
    to: 100.0, 
    duration: 0.6, 
    timingFunction: UnitBezier.easeIn)

let animator = Animator(animation: animation)
    .onChange { value in
        /// Do something with the value.
    }
    .onCancel {
        /// The animation was cancelled before it could finish.
    }
    .onFinish {
        /// The animation finished successfully.
    }

/// Kick off the animation
animator.start()

```

The resulting animator can be used to cancel the animation or to add additional observers or completion handlers.

#### `Simulator` / `Spring`

In most scenarios, physics-based animations are simply run to completion. For those situations, `Animator` and `PropertyAnimator` make it easy to run and use the results of an animation.

In contrast, `Simulator` is useful for scenarios where you need direct access to a running simulation. This might occur in a UI where the user's scroll position drives changes to a spring's tension, for example. It would be impractical to create and start a new animation every time the simulation needs to change. A `Simulator` instance provides mutable access to the `function` property (containing the underlying function that is driving the simulation), along with the current state of the simulation (value and velocity).

`Simulator` conforms to `Observable`, so you can easily be notified when the simulated value changes.

**Spring** is a specialized simulator that uses a spring function. If all you are after is a simple spring to animate a value, this is what you want.


### Animations


There are two primary types of animations in Advance: **Simulated Animations** and **Basic Animations**.

**Basic animations** are conventional animations similar to those seen in most animation libraries: they have a duration and timing function which are used to interpolate between a start and end value as the animation progresses.

**Simulated animations** use a physics-based approach to model changes to a value over time. This allows for realistic animations that model real-world behavior.

Simulated animations are powered by a **Simulation Function**. These functions compute the forces that should effect the animated value for every frame, and control *convergence* (or: when the simulation should come to rest). The included simulation functions are:
- Spring
- Decay
- Gravity


## Contributing

*Suggestions / pull requests / etc. are welcome!*

## Usage

There are several ways to integrate Advance into your project.

* Manually, as a framework: simply add the `Advance.xcodeproj` to your project and add `Advance.framework` as an "Embedded Binary" to your application target (under General in target settings). From there, add `import Advance` to your code and you're good to go.

* Carthage: add `github "timdonnelly/Advance" "master"` to your `Cartfile`.

* CocoaPods: add `pod 'Advance', '~> 2.0'` to your `Podfile`.

##### Requirements
* iOS 10+, tvOS 10+, or macOS 10.12+
* Swift 4.0+ (Xcode 9 or higher)

[Please see the documentation](http://timdonnelly.github.io/Advance/) and check out the sample app (AdvanceSample) in the project for more details.

## Documentation
API documentation is [available here](http://timdonnelly.github.io/Advance/docs).

## License
This project is released under the [BSD 2-clause license](https://github.com/timdonnelly/Advance/blob/master/LICENSE).
