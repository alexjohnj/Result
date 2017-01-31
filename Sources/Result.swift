/**

The `Result<T>` type can be used to represent the success or failure of an
operation. It has two possible cases, `.ok` or `.fail` indicating success and
failure respectively. In the case of success, the result type wraps a value of
type `T`. In the case of failure, the result type wraps a value conforming to
the `Error` protocol.

# Usage

Use one of the many initialisers to create a `Result` value or manually wrap a
value using `Result.ok(val)`. Since Cocoa makes so much use of the try/catch
pattern, one of the initialisers can automatically create a `Result` value from
a throwing function:

```
let data = "{\"result\": \"test\"}".data(using: .utf8)!
let result = Result(try JSONSerialization.jsonObject(with: data))
```

If `jsonObject(with:)` throws, `result` will wrap the thrown error with a
`.fail` case. Otherwise it will wrap the returned data with a `.ok`
case. You can do the inverse and convert a `Result<T>` to a throw (?) using the
`dematerialize()` function:

```
do {
  let jsonObject = try result.dematerialize()
} catch {
  // handle the JSON error
}
```

There's even a nice initialisers for handling optional values:

```
let jsonDict = Result(jsonObject as? [String: String], error: JSONError)
```

If the result of `jsonObject as? [String: String]` is non-nil, we get the value
wrapped in a `.ok` case. Otherwise we get `error` wrapped in a `.fail`
case. Neat!

*/
public enum Result<T> {
    case ok(T)
    case fail(Error)

    // MARK: Initialization

    /// Initialise a `Result<T>` value with a `.ok` case wrapping `val`.
    ///
    /// - parameter val: The value to wrap in a `.ok` case.
    public init(val: T) {
        self = .ok(val)
    }

    /// Initialise a `Result<T>` value with a `.fail` case wrapping `error`.
    ///
    /// - parameter error: An `Error` conforming value to wrap in a `.fail` case.
    /// - Note: You'll need to specify what `T` is for the compiler.
    public init(error: Error) {
        self = .fail(error)
    }

    /// Initialise from a `Result<T>` from an `T?`. If `T?` is nil, wrap `error`
    /// in a `.fail` case, otherwise wrap `T` in a `.ok` case.
    ///
    /// - parameter val: Optional value to wrap.
    /// - parameter error: Error to wrap if `val` is `nil`.
    public init(_ val: T?, error: Error) {
        switch val {
        case .some(let wrapped): self = .ok(wrapped)
        case .none: self = .fail(error)
        }
    }

    /// Initialise from the result of an implicit throwing function. If the
    /// function throws, wrap the throw error in a `.fail` case. Otherwise wrap
    /// the return value in a `.ok` case.
    ///
    /// - parameter f: An implicit throwing function.
    public init(_ f: @autoclosure () throws -> T) {
        self.init(try: f)
    }

    /// Initialise from the result of an throwing function. If the
    /// function throws, wrap the throw error in a `.fail` case. Otherwise wrap
    /// the return value in a `.ok` case.
    ///
    /// - parameter f: An throwing function.
    public init(try f: () throws -> T) {
        do {
            self = .ok(try f())
        } catch let err {
            self = .fail(err)
        }
    }

    // MARK: Properties

    /// Returns an optional `T` containing `self`'s wrapped value if `self` is
    /// `.ok` or `nil` if self is `.fail`.
    public var value: T? {
        get {
            switch self {
            case .ok(let val): return val
            case .fail: return nil
            }
        }
    }

    // MARK: Devolution

    /// Converts a `Result<T>` vale to a `T` value throwing the wrapped error if
    /// `self` is `.fail`.
    public func dematerialize() throws -> T {
        switch self {
        case .ok(let val): return val
        case .fail(let error): throw(error)
        }
    }

    // MARK: Monadic Functions

    /// Applies the function `f` to a `Result<T>` if it is `.ok` and re-wraps
    /// the resulting value. If `self` is `.fail`, `f` is never called and the
    /// error simply passes through to the new `Result<U>`.
    public func map<U>(_ f: ((T) -> U)) -> Result<U> {
        switch self {
        case .ok(let val): return .ok(f(val))
        case .fail(let error): return .fail(error)
        }
    }

    /// Applies the failable function `f` to a `Result<T>` if it is `.ok` to
    /// produce a new `Result<U>`. Like `map`, if `self` is `.fail`, `f` is
    /// never called and the error simply passes through to the new `Result<U>`.
    public func flatMap<U>(_ f: ((T) -> Result<U>)) -> Result<U> {
        switch self {
        case .ok(let val): return f(val)
        case .fail(let error): return .fail(error)
        }
    }
}
