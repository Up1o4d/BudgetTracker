@testable import BudgetTracker

/// Drives an `AsyncStream` iterator from a reference type so a "did anything else arrive" check can
/// race the next value against a timeout without fighting `Iterator`'s value-semantics/mutating
/// requirements. Generic over the element so it works for any `DataState<Element>` stream.
nonisolated final class StreamRecorder<Element: Sendable>: @unchecked Sendable {
    private var iterator: AsyncStream<DataState<Element>>.Iterator

    init(_ stream: AsyncStream<DataState<Element>>) {
        iterator = stream.makeAsyncIterator()
    }

    func next() async -> DataState<Element>? {
        await iterator.next()
    }

    /// Skips interim `.loading` emissions and returns the next settled (`.idle`/`.error`) state.
    func nextSettled() async -> DataState<Element>? {
        while let state = await next() {
            if state.loadingState != .loading { return state }
        }
        return nil
    }

    /// `.none` if nothing arrived before `timeout`; `.some(value)` (possibly `.some(nil)`) otherwise.
    func nextOrTimeout(_ timeout: Duration = .milliseconds(200)) async -> DataState<Element>?? {
        await withTaskGroup(of: Outcome<Element>.self) { group in
            group.addTask { .value(await self.next()) }
            group.addTask {
                try? await Task.sleep(for: timeout)
                return .timeout
            }
            let outcome = await group.next()!
            group.cancelAll()
            switch outcome {
            case .value(let value): return .some(value)
            case .timeout: return .none
            }
        }
    }

    private enum Outcome<T: Sendable>: Sendable {
        case value(DataState<T>?)
        case timeout
    }
}
