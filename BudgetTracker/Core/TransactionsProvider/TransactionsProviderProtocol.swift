protocol TransactionsProviderProtocol: Sendable {
    func fetchTransactions() async throws -> [Transaction]
    func addTransactions(_ newTransactions: [Transaction]) async throws
}
