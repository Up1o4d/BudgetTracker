@testable import BudgetTracker
import Foundation

final class MockTransactionsProvider: TransactionsProviderProtocol, @unchecked Sendable {
    var stubbedTransactions: [Transaction] = []
    var stubbedError: Error?
    private(set) var fetchTransactionsCallCount = 0
    private(set) var lastFilter: TransactionFilter?
    private(set) var transactionsStreamCallCount = 0

    private struct Subscription {
        let continuation: AsyncStream<DataState<Transaction>>.Continuation
        var filter: TransactionFilter?   // nil until the first fetch binds this stream's filter
        var lastData: [Transaction]
    }

    private var streamRegistry: [UUID: Subscription] = [:]

    func transactionsStream() async -> (AsyncStream<DataState<Transaction>>, UUID) {
        transactionsStreamCallCount += 1

        let (stream, continuation) = AsyncStream.makeStream(of: DataState<Transaction>.self)
        let id = UUID()

        continuation.onTermination = { [weak self] _ in
            self?.streamRegistry.removeValue(forKey: id)
        }

        // Silent channel: nothing is emitted until the first `fetchTransactions(uuid:filter:)`
        // binds a filter and pushes content, matching the real providers' contract.
        streamRegistry[id] = Subscription(continuation: continuation, filter: nil, lastData: [])

        return (stream, id)
    }

    @discardableResult
    func fetchTransactions(uuid: UUID, filter: TransactionFilter) async -> Result<[Transaction], Error> {
        fetchTransactionsCallCount += 1
        lastFilter = filter

        guard streamRegistry[uuid] != nil else { return .success([]) }

        // Bind the filter to this stream so later write-driven re-emits stay correctly scoped.
        streamRegistry[uuid]?.filter = filter

        let settled = settledDataState(for: filter, lastData: streamRegistry[uuid]?.lastData ?? [])
        streamRegistry[uuid]?.lastData = settled.data
        streamRegistry[uuid]?.continuation.yield(settled)

        return settled.loadingState == .error
            ? .failure(settled.error ?? stubbedError ?? NSError(domain: "MockTransactionsProvider", code: 0))
            : .success(settled.data)
    }

    func addTransactions(_ newTransactions: [Transaction]) async throws {
        stubbedTransactions.append(contentsOf: newTransactions)

        // Re-emit only for streams that have been fetched (filter bound); never-fetched streams
        // stay silent, matching the real registry's write-driven re-emit.
        for id in streamRegistry.keys {
            guard let subscription = streamRegistry[id], let filter = subscription.filter else { continue }
            let settled = settledDataState(for: filter, lastData: subscription.lastData)
            streamRegistry[id]?.lastData = settled.data
            subscription.continuation.yield(settled)
        }
    }

    /// Test hook: emit an interim `.loading` carrying the last-known data to every active
    /// stream — exactly what a real provider does while a refresh is in flight. Lets tests
    /// verify a consumer keeps its list visible instead of blanking it.
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

    private func settledDataState(for filter: TransactionFilter, lastData: [Transaction]) -> DataState<Transaction> {
        if let error = stubbedError {
            return DataState(loadingState: .error, data: lastData, error: error)
        }
        return DataState(loadingState: .idle, data: stubbedTransactions.filter { filter.matches($0) })
    }
}
