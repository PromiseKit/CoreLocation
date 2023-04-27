# PromiseKit CoreLocation Extensions ![Build Status]

This project adds promises to Apple’s CoreLocation framework.

## CocoaPods

```ruby
pod "PromiseKit/CoreLocation", "~> 6.0"
```

The extensions are built into `PromiseKit.framework` thus nothing else is needed.

## Carthage

```ogdl
github "PromiseKit/CoreLocation" ~> 3.1.2
```

## Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/PromiseKit/CoreLocation.git", .upToNextMajor(from: "3.1.2"))
]
```

The extensions are built into their own framework:

```swift
// swift
import PromiseKit
import PMKCoreLocation
```

```objc
// objc
@import PromiseKit;
@import PMKCoreLocation;
```


[Build Status]: https://travis-ci.org/PromiseKit/CoreLocation.svg?branch=master
