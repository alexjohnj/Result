public enum Result<T> {
    case ok(T)
    case fail(Error)

    // MARK: Initialization

    public init(val: T) {
        self = .ok(val)
    }

    public init(error: Error) {
        self = .fail(error)
    }

    /// Initialise from an optional T wrapping the value if it is non-nil or `error` otherwise.
    public init(_ val: T?, error: Error) {
        switch val {
        case .some(let wrapped): self = .ok(wrapped)
        case .none: self = .fail(error)
        }
    }

    /// Initialise from the result of a throwing function, wrapping the thrown error if the function throws.
    public init(_ f: @autoclosure () throws -> T) {
        self.init(try: f)
    }

    /// Initialise from the result of a throwing function, wrapping the thrown error if the function throws.
    public init(try f: () throws -> T) {
        do {
            self = .ok(try f())
        } catch let err {
            self = .fail(err)
        }
    }

    // MARK: Properties
    /// Returns the wrapped value if it is wrapped by `.ok`. Otherwise returns `nil`.
    public var value: T? {
        get {
            switch self {
            case .ok(let val): return val
            case .fail: return nil
            }
        }
    }

    // MARK: Devolution

    /// Converts a `Result<T>` type to a `T` throwing if the value is `.fail`.
    public func dematerialize() throws -> T {
        switch self {
        case .ok(let val): return val
        case .fail(let error): throw(error)
        }
    }

    // MARK: Monadic Functions

    /// Applies the function `f` to a `Result<T>` if it is `.ok` and re-wraps the resulting value.
    public func map<U>(_ f: ((T) -> U)) -> Result<U> {
        switch self {
        case .ok(let val): return .ok(f(val))
        case .fail(let error): return .fail(error)
        }
    }

    /// Applies the function `f` to a `Result<T>` if it is `.ok` to produce a new `Result<U>`.
    public func flatMap<U>(_ f: ((T) -> Result<U>)) -> Result<U> {
        switch self {
        case .ok(let val): return f(val)
        case .fail(let error): return .fail(error)
        }
    }
}
