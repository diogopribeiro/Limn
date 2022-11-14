# Limn

[![Swift Version](https://img.shields.io/badge/swift-5.6-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/github/license/diogopribeiro/Limn.svg)](https://github.com/diogopribeiro/Limn/blob/master/LICENSE)

Limn is a Swift library for inspecting and comparing values in Swift and Objective-C. It was conceived as a more concise and complete alternative to Swift's `dump()` and over time it gained other helpful features for debugging such as support for persistence, diffing and filtering of child elements.

1. [Overview](#overview)
1. [Installation](#installation)
1. [Customization](#customization)
1. [Known issues and limitations](#known-issues-and-limitations)
1. [Contributing](#contributing)
1. [License](#license)

## Overview

Swift provides a couple of ways to convert the contents of any value to a string - the most complete of these being `dump()`. However, its output format can sometimes be a bit too verbose and difficult to read, especially when the given value contains complex types and/or many child elements:

```swift
dump(supportedHTTPStatusCodes)
```
> ```swift
> ▿ 3 key/value pairs
>   ▿ (2 elements)
>     ▿ key: Range(400..<500)
>       - lowerBound: 400
>       - upperBound: 500
>     ▿ value: 2 key/value pairs
>       ▿ (2 elements)
>         - key: 404
>         - value: "Not Found"
>       ▿ (2 elements)
>         - key: 403
>         - value: "Forbidden"
>   ▿ (2 elements)
>     ▿ key: Range(500..<600)
>       - lowerBound: 500
>       - upperBound: 600
>     ▿ value: 2 key/value pairs
>       ▿ (2 elements)
>         - key: 503
>         - value: "Service Unavailable"
>       ▿ (2 elements)
>         - key: 500
>         - value: "Internal Server Error"
>   ▿ (2 elements)
>     ▿ key: Range(200..<300)
>       - lowerBound: 200
>       - upperBound: 300
>     ▿ value: 1 key/value pair
>       ▿ (2 elements)
>         - key: 200
>         - value: "OK"
> ```

Limn was originally developed as a more concise alternative to `dump()`. Its default output style is similar to Swift code, which is typically shorter and easier to read:

```swift
Limn(of: supportedHTTPStatusCodes).sorted().dump()
```
> ```swift
> [
>     200..<300: [
>         200: "OK"
>     ],
>     400..<500: [
>         403: "Forbidden",
>         404: "Not Found"
>     ],
>     500..<600: [
>         500: "Internal Server Error",
>         503: "Service Unavailable"
>     ]
> ]
> ```

Limn can print its contents to a `String` using method `.stringDump()` or to the standard output (or a `TextOutputStream`) using method `.dump()`. These methods offer numerous formatting options, ranging from the indentation level to use to the maximum number of child elements to display for each value. It's even possible to mimic other languages and file formats such as JSON:

```swift
Limn(of: playerInfo).dump(format: .json(minified: false))
```
> ```json
> {
>     "name": "Hanna",
>     "highScore": 30441,
>     "history": [
>         27801,
>         29383,
>         26774
>     ]
> }
> ```

Contrary to `dump()`, Limn can also properly extract the contents of Objective-C values using the [Runtime](https://developer.apple.com/documentation/objectivec/objective-c_runtime) API (in addition to the [Mirror](https://developer.apple.com/documentation/swift/mirror) API used for Swift values):

```swift
Limn(of: UIView(), maxDepth: 3).sorted().dump(format: .init(maxItems: 4))
```
> ```swift
> UIView(
>     __alignmentRectOriginCache: nil,
>     __lastNotifiedTraitCollection: UITraitCollection(
>         _builtinTraits: ?(…),
>         _clientDefinedTraits: nil,
>         _environmentWrapper: nil
>     ) @ 0x00014cd9e980,
>     … (33 more),
>     _viewFlags: ?(
>         accessibilityIgnoresInvertColors: false,
>         accessibilityInterfaceStyleIntent: false,
>         … (137 more),
>         wantsAutolayout: false,
>         wantsDeepColorDrawing: false
>     ),
>     _window: nil
> ) @ 0x00012f10e5e0
> ```

Two values can be compared using `.diff(to:)` or `Limn.diff(from:to:)`. These methods return a `Limn` instance containing both the original and updated values, which are printed as a git-style diff by default:

```swift
let before = Player(name: "Tomas", highScore: 17126, history: [12703, 11945, 17126])
let after = Player(name: "Tomas", highScore: 17399, history: [12703, 11945, 17126, 17399])

Limn.diff(from: before, to: after).dump()
```
> ```diff
>   Player(
>       … (1 unchanged),
> -     highScore: 17126,
> +     highScore: 17399,
>       history: [
>           … (3 unchanged),
> +         17399
>       ]
>   )
> ```

`Limn`s can be persisted on the app's container, which may be useful to store certain values for later comparison:

```swift
struct MainView: View {

    var body: some View {

        // Print the changes on this SwiftUI View as it gets updated:
        let newValue = Limn(of: self, maxDepth: 5)
        Limn.load("prevValue")?.diffed(to: newValue).dump()
        newValue.save(as: "prevValue")

        return ZStack {
            // ...
        }
    }
}
```
> ```diff
>   MainView(
>       _session: EnvironmentObject<Session>(
>           _store: Session(
>               … (9 unchanged),
>               settings: Settings(
>                   … (3 unchanged),
>                   _endpointHost: AppStorage<String>(
>                       location: UserDefaultLocation<String>(
>                           … (5 unchanged),
> -                         cachedValue: "192.168.1",
> +                         cachedValue: "192.168.1.",
>                           … (5 unchanged)
>                       ) @ 0x600001fa4750
>                   ),
>                   … (7 unchanged)
>               ) @ 0x600000688c40,
>               … (8 unchanged)
>           ) @ 0x0001436085b0,
> -         _seed: 67
> +         _seed: 68
>       ),
>       … (5 unchanged)
>   )
> ```

Contents of a `Limn` hierarchy can also be filtered by either a value's description and/or its display style:

```swift
Limn(of: supportedHTTPStatusCodes).filtered(value: "503").dump()
```
> ```swift
> [
>     … (3 filtered),
>     500..<600: [
>         … (1 filtered),
>         503: "Service Unavailable"
>     ]
> ]
> ```

Specific child values or collection elements can be selected using a subscript. This can be particularly useful to isolate inaccessible child properties from their accessible parents or to access specific elements on overly large collections:

```swift
Limn(of: UIView())["_inferredLayoutMargins"]?.dump()
```
> ```swift
> UIEdgeInsets(
>     top: 42.0,
>     left: 8.0,
>     bottom: 16.0,
>     right: 8.0
> )
> ```

Statistics and similar information can be gathered using the `.stats()` method:

```swift
Limn(of: UIViewController()).stats()
```
> ```swift
> ▿ Stats
>   - diffedEntriesCount : 0
>   - filteredEntriesCount : 0
>   - maxDepth : 4
>   ▿ typeNames : 8 elements
>     - 0 : "CGSize"
>     - 1 : "CGPoint"
>     - 2 : "CGRect"
>     - 3 : "NSDirectionalEdgeInsets"
>     - 4 : "UIKit.UITraitCollection"
>     - 5 : "UIViewController"
>     - 6 : "UIEdgeInsets"
>   - unresolvedEntriesCount : 0
> ```

Other minor features include support for undiffing and sorting of (non-indexed) elements.

## Installation

Limn can be added to your project using [Swift Package Manager](https://www.swift.org/package-manager/), [CocoaPods](https://cocoapods.org/) or as an Xcode subproject.

To import Limn with [Cocoapods](https://cocoapods.org/), add the following dependency to your `Podfile`:

```podspec
pod 'Limn'
```

## Customization

#### `CustomLimnRepresentable`

The representation of a type (and its children) can be fully customized in case you're not happy with the defaults. By conforming the desired type to the `CustomLimnRepresentable` protocol you can:

- Adjust its type name by implementing the static property `customLimnTypeName`;
- Return a fully customized `Limn` for an instance by implementing method `customLimn(defaultLimn:context:)`.

Example:

```swift
extension UIControl.State: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIControl.State.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .application: caseName = "application"
        case .disabled: caseName = "disabled"
        case .focused: caseName = "focused"
        case .highlighted: caseName = "highlighted"
        case .normal: caseName = "normal"
        case .reserved: caseName = "reserved"
        case .selected: caseName = "selected"
        default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}
```

Limn provides [several implementations](Sources/Limn/Customization/BuiltIn/) of `CustomLimnRepresentable` out of the box for commonly used types (including the example seen above).

#### `DumpFormat`

The default output format used by `.dump()` and `.stringDump()` can be modified by adjusting properties of `Limn.DumpFormat.default` (e.g. `Limn.DumpFormat.default.maxItems = 4`). To create a reusable format, add an extension of `Limn.DumpFormat` and declare your style as a static property returning `Self`. This format can then be passed to methods `.dump(format:)` and `.stringDump(format:)`.

## Known issues and limitations

- Diffing feature requires [`Array.difference(from:by:)`](https://developer.apple.com/documentation/swift/array/difference(from:by:)), which is only available if the library is compiled with the following targets or above:
    - iOS 13.0
    - macOS 10.15
    - watchOS 6.0
    - tvOS 13.0
  
- Objective-C support is incomplete as of v0.9.X. Some less common data types will not be parsed.

- Due to limitations of the language, it's not possible to obtain Swift-like fully qualified names from Objective-C types (e.g. a `UIKit.UIControl.State` value is identified as `__C.UIControlState` by default).
    - This can be fixed by customizing the type name though `CustomLimnRepresentable`. Several extensions are provided in the [`Customization/BuiltIn`](Sources/Limn/Customization/BuiltIn) folder.

- When diffing, two instances from types that conform to `Equatable` will be wrongly identified as having no changes if the result from the `==` operator is `false` but their `Limn` descriptions are identical.

## Contributing

All contributions are welcome! You can open a discussion first if you wish to talk about some topic prior to the development and submission.
Please try to match the existing code style if you open a PR.

## License

Limn is provided with an MIT License. See the [LICENSE](LICENSE) file for more details.
