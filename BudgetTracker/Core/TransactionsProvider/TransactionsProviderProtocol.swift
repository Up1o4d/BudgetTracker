protocol TransactionsProviderProtocol {
    func fetchTransactions() async throws -> [Transaction]
    func addTransactions(_ newTransactions: [Transaction]) async throws
}
