protocol TransactionsProviderProtocol: Sendable {
    func fetchTransactions(filter: TransactionFilter) async throws -> [Transaction]
    func addTransactions(_ newTransactions: [Transaction]) async throws
}

extension TransactionsProviderProtocol {
    func fetchTransactions() async throws -> [Transaction] {
        try await fetchTransactions(filter: TransactionFilter())
    }
}
