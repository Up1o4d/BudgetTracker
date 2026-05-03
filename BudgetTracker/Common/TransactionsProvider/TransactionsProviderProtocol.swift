protocol TransactionsProviderProtocol {
    func fetchTransactions() async -> [Transaction]
}
