@testable import BudgetTracker
import Foundation

final class MockTransactionsProvider: TransactionsProviderProtocol, @unchecked Sendable {
    var stubbedTransactions: [Transaction] = []
    var stubbedError: Error?
    private(set) var fetchTransactionsCallCount = 0
    private(set) var lastFilter: TransactionFilter?
    private(set) var transactionsStreamCallCount = 0
    private(set) var lastStreamFilter: TransactionFilter?

    private struct Subscription {
        let filter: TransactionFilter
        let continuation: AsyncStream<DataState<Transaction>>.Continuation
        var lastData: [Transaction]
    }

    private var streamRegistry: [UUID: Subscription] = [:]

    func fetchTransactions(filter: TransactionFilter) async throws -> [Transaction] {
        fetchTransactionsCallCount += 1
        lastFilter = filter
        if let error = stubbedError { throw error }
        return stubbedTransactions.filter { filter.matches($0) }
    }

    func transactionsStream(filter: TransactionFilter) async -> AsyncStream<DataState<Transaction>> {
        transactionsStreamCallCount += 1
        lastStreamFilter = filter

        let (stream, continuation) = AsyncStream.makeStream(of: DataState<Transaction>.self)
        let id = UUID()

        continuation.onTermination = { [weak self] _ in
            self?.streamRegistry.removeValue(forKey: id)
        }

        let settled = settledDataState(for: filter, lastData: [])
        streamRegistry[id] = Subscription(filter: filter, continuation: continuation, lastData: settled.data)
        continuation.yield(settled)

        return stream
    }

    func addTransactions(_ newTransactions: [Transaction]) async throws {
        stubbedTransactions.append(contentsOf: newTransactions)

        for id in streamRegistry.keys {
            guard let subscription = streamRegistry[id] else { continue }
            let settled = settledDataState(for: subscription.filter, lastData: subscription.lastData)
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
