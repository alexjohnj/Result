public enum Result<T> {
    case ok(T)
    case fail(Error)
}

extension Result where T: Equatable {
    static func ==(lhs: Result<T>, rhs: Result<T>) -> Bool {
        switch (lhs, rhs) {
        case (.ok(let left), .ok(let right)): return left == right
        default: return false
        }
    }
}
