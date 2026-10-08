import Foundation

public actor Debouncer {
    private let nanoseconds: UInt64
    private var task: Task<Void, Never>?

    public init(milliseconds: UInt64 = 350) {
        self.nanoseconds = milliseconds * 1_000_000
    }

    public func debounce(_ operation: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            do {
                try await Task.sleep(nanoseconds: nanoseconds)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            await operation()
        }
    }

    public func cancel() {
        task?.cancel()
        task = nil
    }
}
