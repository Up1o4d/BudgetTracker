protocol TransactionsProviderProtocol {
    func fetchTransactions() async throws -> [Transaction]
}
