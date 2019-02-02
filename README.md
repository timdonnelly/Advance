# Advance

Physics-based animations for iOS, tvOS, and macOS.

## Usage

In contrast to standard `UIView` animations, Advance animations are applied on every frame (using `CADisplayLink` on iOS).

```swift
let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

/// Animators coordinate animations to drive changes to a value.
let sizeAnimator = Animator(boundTo: view, keyPath: \.bounds.size)

/// Spring physics will move the view's size to the new value.
sizeAnimator.spring(to: CGSize(width: 300, height: 300))

/// Some time in the future...

/// The value will keep the same velocity that it had from the preceeding
/// animation, and a decay function will slowly bring movement to a stop.
sizeAnimator.decay(drag: 2.0)

```

```swift
let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

/// Springs are... springs. That's all they do.
let spring = Spring(boundTo: view, keyPath: \.center)

/// The view's center will realistically animate to the new value.
spring.target = CGPoint(x: 300, y: 200)
```


### Animator

`Animator` drives changes to a value over time using animations (conforming to the `Animation` protocol).

The current velocity of the value is available though the `velocity` property, making it easy to transition between animations of different types while maintaining fluid motion.

A set of extensions make it easy to kick off animations on an animator:

```swift
let view = UIView()
let boundsAnimator = Animator(boundTo: view, keyPath: \.bounds)

/// Basic animation
boundsAnimator.animate(to: CGRect(x: 0, y: 0, width: 300, height: 300), duration: 0.5, timingFunction: UnitBezier.easeIn)

/// or...

/// Spring
boundsAnimator.spring(to: CGRect(x: 0, y: 0, width: 300, height: 300))

/// or...

/// Decay
boundsAnimator.decay(initialVelocity: CGRect(x: 30, y: 30, width: 30, height: 30))

```

Each of these methods returns an `AnimationRunner<Value>` instance, which can be used to add completion handlers, wire up additional observers for the running animation, etc.

### Simulator / Spring
`Simulator` uses a physics-based simulation to realistically model changes to a value over time.

In most scenarios animations are set up once, then run to completion. `Animator` takes are of that simple case with a flexible API that allows you to use any type of animation to drive the value.

In contrast, `Simulator` is a focused class that is useful for scenarios where you need direct access to a running simulation. This might occur in a UI where the user's scroll position drives changes to a spring's tension, for example. It would be impractical to create and start a new animation every time the simulation needs to change. A `Simulator` instance provides mutable access to the `function` property (containing the underlying function that is driving the simulation), along with the current state of the simulation (value and velocity).

`Simulator` conforms to `Observable`, so you can easily be notified when the simulated value changes.

```swift
let function = GravityFunction(target: CGPoint(20, 20).vector)
let simulator = Simulator(function: function, value: CGPoint.zero)
simulator.observe { value in
    /// Apply the new value.
}
```

#### Spring
`Spring` is a specialized simulator that uses a spring function. If all you are after is a simple spring to animate a value, this is what you want.

Convenience extensions provide full access to the underlying spring simulation (target, tension, damping, velocity, etc) at any time: even while the simulation is in progress.

```swift
let spring = Spring(boundTo: view, keyPath: \.alpha)
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

#### Simulation Functions

Simulations are powered by a **Simulation Function**. These functions compute the forces that should effect the value for every frame, and control *convergence* (or: when the simulation should come to rest). The included simulation functions are:
- `SpringFunction`
- `DecayFunction`
- `GravityFunction`


### Animations

Values conforming to the `VectorConvertible` protocol can be animated by Advance. Conforming types can be converted to and from a `Vector` implementation.
```swift
public protocol VectorConvertible: Equatable, Interpolatable {
    associatedtype VectorType: Vector
    init(vector: VectorType)
    var vector: VectorType { get }
}
```

There are two primary types of animations in Advance: **Simulated Animations** and **Basic Animations**.

#### Basic Animations
`BasicAnimation` implements a conventional animation similar to those seen in most animation libraries: it has a duration and timing function which are used to interpolate between a start and end value as the animation progresses.

##### Timing Functions

Basic animations use a timing function to control the pacing of the value's change over the course of the animation. Timing functions are types conforming to the `TimingFunction` protocol. Advance includes the following timing function implementations.

- `LinearTimingFunction` 
- `UnitBezier`
- `CAMediaTimingFunction` (`TimingFunction` conformance via an extension)


#### Simulated animations
`SimulatedAnimation` uses a physics-based approach to model changes to a value over time, enabling realistic animations that model real-world behavior. `SimulatedAnimation` allows you to use simulation functions as animations (most commonly with an `Animator` instance).

#### Creating animations

Convenience extensions make it easy to generate animations from `VectorConvertible` types.

```swift
let springAnimation = CGPoint.zero.springAnimation(to: CGPoint(x: 100, y: 100))

/// Also try `.animation(to:duration:timingFunction:)` and `.decayAnimation(drag:)`.

let animator: Animator<CGPoint> = /// ...

animator.animate(with: springAnimation)

```



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
* Swift 4.2 (Xcode 10 or higher)

## Documentation
API documentation is [available here](http://timdonnelly.github.io/Advance/).

## License
This project is released under the [BSD 2-clause license](https://github.com/timdonnelly/Advance/blob/master/LICENSE).
