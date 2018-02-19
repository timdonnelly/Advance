<br/><img src="https://github.com/storehouse/Advance/raw/master/Assets/logo.png" width="302">

A powerful animation framework for iOS, tvOS, and OS X.

---

##### What is it?
Advance is a Swift framework that enables advanced animations and physics-based interactions.

Originally developed to power the animations throughout the Storehouse app for iOS, Advance has evolved into a composable set of tools with a [simple API](http://timdonnelly.github.io/Advance/docs).

### Examples

##### Use a spring to animate UI

```swift
import Advance

let spring = Spring(value: CGPoint.zero)
spring.values.bind(to: view, keyPath: \.center)
spring.target = CGPoint(x: 300, y: 200)

```
The spring will then animate the movement of the view to the new `target` position.

****

##### Animate between values

```swift
import Advance

let animator = 0.0
    .animation(to: 100.0, duration: 0.6, timingFunction: .easeIn)
    .run()
    .bind(to: myObject, keyPath: \.propertyName)
    .onCompletion { result in
        /// Do something when the animation finishes.
    }

```

The resulting animator can be used to cancel the animation or to add additional observers or completion handlers.

****

##### Check out the sample app
Located in the project:

![Sample app](https://github.com/timdonnelly/Advance/raw/master/Assets/nav.gif)
![Sample app](https://github.com/timdonnelly/Advance/raw/master/Assets/logo.gif)

****

##### Should I use it?
Advance shines when:

* You are building gesture-based interactions that use physics to reflect the behavior of the real world.
* You need to animate custom types with per-frame callbacks.
* ???. Advance is extensible, making it easy to build custom animation and simulation types.

##### Requirements
* iOS 10+, tvOS 10+, or OS X 10.12+
* Swift 4.0+ (Xcode 9 or higher)

[Please see the documentation](http://timdonnelly.github.io/Advance/docs) and check out the sample app (AdvanceSample) in the project for more details.

### Notes

##### Thread safety

Advance classes are **not** thread safe, and expect to be used from the main thread only.

### Status

*Suggestions / pull requests / etc are welcome!*

### Usage

There are several ways to integrate Advance into your project.

* Manually, as a framework: simply add the `Advance.xcodeproj` to your project and add `Advance.framework` as an "Embedded Binary" to your application target (under General in target settings). From there, add `import Advance` to your code and you're good to go.

* Swift Package Manager (experimental).

* Carthage: add `github "timdonnelly/Advance" "master"` to your `Cartfile`.

* CocoaPods: add `pod 'Advance', '~> 0.9'` to your `Podfile`.

### Documentation
API documentation is [available here](http://timdonnelly.github.io/Advance/docs).

### License
This project is released under the [BSD 2-clause license](https://github.com/timdonnelly/Advance/blob/master/LICENSE).
