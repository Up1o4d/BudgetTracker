@testable import BudgetTracker

final class MockTransactionsProvider: TransactionsProviderProtocol, @unchecked Sendable {
    var stubbedTransactions: [Transaction] = []
    var stubbedError: Error?
    private(set) var fetchTransactionsCallCount = 0
    private(set) var lastFilter: TransactionFilter?

    func fetchTransactions(filter: TransactionFilter) async throws -> [Transaction] {
        fetchTransactionsCallCount += 1
        lastFilter = filter
        if let error = stubbedError { throw error }
        return stubbedTransactions.filter { filter.matches($0) }
    }

    func addTransactions(_: [Transaction]) async throws {}
}
