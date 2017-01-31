# Result

This is a simple package for Swift that adds a `Result<T>` type to indicate
success or failure. I'm aware there's already a bunch of packages that do this,
notably [antitypical/Result][result-framework], but I don't like that this uses
a generic type parameter on the error value as well as the wrapped value. I find
I spend too much time trying to satisfy the type system for relatively small
gains in safety.

The **key difference** with this package is you only need to specify the type of
the wrapped value, not the error value.

[result-framework]: https://github.com/antitypical/Result

## Installation

Install using the Swift package manager by modifying `Package.swift`:

```
import PackageDescription

let package = Package(
    name: "AwesomePackage",
    dependencies: [
        .Package(url: "https://github.com/alexjohnj/Result",
                 majorVersion: 1)
    ]
)
```

## Usage

Checkout [Result.swift][result-file-link] for some detailed comments on
usage. There's also the tests for some unrealistic usage examples. In general,
usage goes something like this:

```swift
let foo = barReturningResult()
switch foo {
    case .ok(let val): doSomethingWith(val)
    case .fail(let error): doSomethingToFix(error)
}
```

`Result<T>` can either be `.ok` or `.fail`. If it's the former, it'll wrap a
value of type `<T>`. If it's the latter, it'll wrap a value conforming to the
`Error` protocol.

`Result<T>` defines an initialiser and a property (`value`) for going between
`Optional<T>` and `Result<T>`. There's also an initialiser and a method
(`dematerialize()`) for converting between Swift's native `throws` error
handling system and `Result<T>`. As a result, _Result_ can integrated quite
nicely with Cocoa and the Swift standard library.

[result-file-link]: https://github.com/alexjohnj/Result/blob/master/Sources/Result.swift#L1

### Functional Functions

There's two useful higher order functions defined for `Result<T>`---`map` and
`flatMap`. The former applies a function to a `Result<T>` that maps `T -> U`
**if** `Result<T>` is `.ok`. Otherwise it just rewraps the error in a
`Result<U>` value. The latter function applies a function to a `Result<T>` that
maps `T -> Result<U>` if `Result<T>` is `.ok`. Again, if `Result<T>` is `.fail`,
the error will be rewrapped in a `Result<U>` value.

## License

MIT
