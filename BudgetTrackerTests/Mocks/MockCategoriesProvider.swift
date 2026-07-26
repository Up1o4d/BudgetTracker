@testable import BudgetTracker
import Foundation

final class MockCategoriesProvider: CategoriesProviderProtocol, @unchecked Sendable {
    var stubbedCategories: [BudgetTracker.Category] = []
    var stubbedError: Error?
    private(set) var fetchCategoriesCallCount = 0
    private(set) var addCategoriesCallCount = 0
    private(set) var categoriesStreamCallCount = 0

    private struct Subscription {
        let continuation: AsyncStream<DataState<BudgetTracker.Category>>.Continuation
        var bound: Bool   // false until the first fetch pushes content down this stream
        var lastData: [BudgetTracker.Category]
    }

    private var streamRegistry: [UUID: Subscription] = [:]

    func categoriesStream() async -> (AsyncStream<DataState<BudgetTracker.Category>>, UUID) {
        categoriesStreamCallCount += 1

        let (stream, continuation) = AsyncStream.makeStream(of: DataState<BudgetTracker.Category>.self)
        let id = UUID()

        continuation.onTermination = { [weak self] _ in
            self?.streamRegistry.removeValue(forKey: id)
        }

        // Silent channel: nothing is emitted until the first `fetchCategories(uuid:)` pushes
        // content, matching the real providers' contract.
        streamRegistry[id] = Subscription(continuation: continuation, bound: false, lastData: [])

        return (stream, id)
    }

    @discardableResult
    func fetchCategories(uuid: UUID) async -> Result<[BudgetTracker.Category], Error> {
        fetchCategoriesCallCount += 1

        guard streamRegistry[uuid] != nil else { return .success([]) }

        // Mark this stream as fetched so later write-driven re-emits reach it.
        streamRegistry[uuid]?.bound = true

        let settled = settledDataState(lastData: streamRegistry[uuid]?.lastData ?? [])
        streamRegistry[uuid]?.lastData = settled.data
        streamRegistry[uuid]?.continuation.yield(settled)

        return settled.loadingState == .error
            ? .failure(settled.error ?? stubbedError ?? NSError(domain: "MockCategoriesProvider", code: 0))
            : .success(settled.data)
    }

    func addCategories(_ categories: [BudgetTracker.Category]) async throws {
        addCategoriesCallCount += 1
        if let error = stubbedError { throw error }
        stubbedCategories.append(contentsOf: categories)

        // Re-emit only for streams that have been fetched; never-fetched streams stay silent,
        // matching the real registry's write-driven re-emit.
        for id in streamRegistry.keys {
            guard let subscription = streamRegistry[id], subscription.bound else { continue }
            let settled = settledDataState(lastData: subscription.lastData)
            streamRegistry[id]?.lastData = settled.data
            subscription.continuation.yield(settled)
        }
    }

    /// Test hook: emit an interim `.loading` carrying the last-known data to every active
    /// stream — exactly what a real provider does while a refresh is in flight.
    func emitLoading() {
        for subscription in streamRegistry.values {
            subscription.continuation.yield(DataState(loadingState: .loading, data: subscription.lastData))
        }
    }

    /// Test hook: emit a `.error` carrying the last-known data to every active stream — a
    /// failed refresh never blanks what was already loaded.
    func emitError(_ error: Error) {
        for subscription in streamRegistry.values {
            subscription.continuation.yield(DataState(loadingState: .error, data: subscription.lastData, error: error))
        }
    }

    private func settledDataState(lastData: [BudgetTracker.Category]) -> DataState<BudgetTracker.Category> {
        if let error = stubbedError {
            return DataState(loadingState: .error, data: lastData, error: error)
        }
        return DataState(loadingState: .idle, data: stubbedCategories)
    }
}
