# CGLayout

[![CI Status](http://img.shields.io/travis/k-o-d-e-n/CGLayout.svg?style=flat)](https://travis-ci.org/k-o-d-e-n/CGLayout)
[![Version](https://img.shields.io/cocoapods/v/CGLayout.svg?style=flat)](http://cocoapods.org/pods/CGLayout)
[![License](https://img.shields.io/cocoapods/l/CGLayout.svg?style=flat)](http://cocoapods.org/pods/CGLayout)
[![Platform](https://img.shields.io/cocoapods/p/CGLayout.svg?style=flat)](http://cocoapods.org/pods/CGLayout)

<p align="center">
    <img src="Resources/logo.png">
</p>

Powerful autolayout framework, that can manage UIView(NSView), CALayer and not rendered views. Has cross-hierarchy coordinate space. Implementation performed on rect-based constraints. Fast, asynchronous, declarative, cacheable, extensible. Supported iOS, macOS, tvOS.

<p align="center">
    <img src="Resources/benchmark_result.png">
</p>
Performed by [LayoutBenchmarkFramework](https://github.com/lucdion/LayoutFrameworkBenchmark)

## Quick tutorial

Layout with `CGLayout` built using layout-blocks. To combine blocks into single unit use `LayoutScheme` entity (or other entities that has suffix `Scheme`).
```swift
let subviewsScheme = LayoutScheme(blocks: [
// ... layout blocks
])
```
To define block for "view" element use `LayoutBlock` entity, or just use convenience getter method `func layoutBlock(with:constraints:)`.
```swift
titleLabel.layoutBlock(with: Layout(x: .center(), y: .top(5), width: .scaled(1), height: .fixed(120)),
                       constraints: [logoImageView.layoutConstraint(for: [LayoutAnchor.Bottom.limit(on: .inner)])])
```
For understanding how need to built layout block, let's see layout process in `LayoutBlock`. 
For example we have this configuration:
```swift
LayoutBlock(with: layoutElement, 
            layout: Layout(x: .left(10), y: .top(10), width: .boxed(10), height: .boxed(10)),
            constraints: [element1.layoutConstraint(for: [LayoutAnchor.Bottom.limit(on: .outer), LayoutAnchor.Right.limit(on: .inner)]),
                          element2.layoutConstraint(for: [LayoutAnchor.Right.limit(on: .outer), LayoutAnchor.Bottom.limit(on: .inner)])])
```
<p align="center">
<img src="Resources/layout1.png">
<img src="Resources/layout2.png">
</p>
You have to carefully approach the creation of blocks, because anchors and based on them constraints not have priority and is applying sequentially.
Constraints should operate actual frames, therefore next layout block must have constraints with "views", that will not change frame.

Layout anchors are limiters, that is oriented on frame properties (such as sides, size, position).
Any side-based anchors have three base implementations: alignment, limitation(cropping), pulling. Each this implementation have dependency on working space: inner and outer.
Size-based anchors are represented by two implementations: size, insets.
For constrain "view" by yourself content use `AdjustLayoutConstraint` or `func adjustLayoutConstraint(for anchors: LayoutAnchor.Size)` getter.
In common case, adjust constraints should be apply after any other constraints (but not always).
```swift
weatherLabel.layoutBlock(with: Layout(x: .left(10), y: .top(), width: .scaled(1), height: .scaled(1)),
                         constraints: [weatherImageView.layoutConstraint(for: [topLimit, rightLimit, heightEqual]),
                                       weatherLabel.adjustLayoutConstraint(for: [.width()])])
```
Use `AnonymConstraint` for constrain source space independently from external environment:
```swift
AnonymConstraint(anchors: [LayoutAnchor.insets(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 15))])
```

Each layout-block has methods for layout, take snapshot and applying snapshot.
Consequently you may use layout-blocks for direct layout, background layout and cached layout:
```swift
// layout directly
layoutScheme.layout()

// layout in background
let bounds = view.bounds
    DispatchQueue.global(qos: .background).async {
    let snapshot = self.layoutScheme.snapshot(for: bounds)
    DispatchQueue.main.sync {
        self.layoutScheme.apply(snapshot: snapshot)
    }
}

// cached layout
if UIDevice.current.orientation.isPortrait, let snapshot = portraitSnapshot {
    layoutScheme.apply(snapshot: snapshot)
} else if UIDevice.current.orientation.isLandscape, let snapshot = landscapeSnapshot {
    layoutScheme.apply(snapshot: snapshot)
} else {
    layoutScheme.layout()
}
```

For implementing custom layout entities and save strong typed code, use `static func build(_ base: Conformed) -> Self` method.

Framework provides `LayoutGuide` as analogue UILayoutGuide. It has possible to generate views and add them to hierarchy.
For create `UIView` placeholders use `ViewPlaceholder` class.

For more details, see documentation and example project.

## Code documentation

See [here](https://k-o-d-e-n.github.io/CGLayout/)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Xcode 8.3+

## Installation

CGLayout is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CGLayout"
```

## Author

k-o-d-e-n, koden.u8800@gmail.com

## License

CGLayout is available under the MIT license. See the LICENSE file for more info.
