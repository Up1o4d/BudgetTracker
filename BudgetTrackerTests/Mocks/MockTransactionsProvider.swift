@testable import BudgetTracker

final class MockTransactionsProvider: TransactionsProviderProtocol {
    var stubbedTransactions: [Transaction] = []
    var stubbedError: Error?
    private(set) var fetchTransactionsCallCount = 0

    func fetchTransactions() async throws -> [Transaction] {
        fetchTransactionsCallCount += 1
        if let error = stubbedError {
            throw error
        }
        return stubbedTransactions
    }

    func addTransactions(_: [Transaction]) async throws {}
}
