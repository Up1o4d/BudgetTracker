protocol TransactionsProviderProtocol: Sendable {
    func fetchTransactions(filter: TransactionFilter) async throws -> [Transaction]

    /// Emits the current filtered set on subscribe, then re-emits after every write.
    /// Implementations that can't refresh synchronously (e.g. a REST-backed provider)
    /// may yield an interim `.loading` state before the settled `.idle`/`.error` state.
    ///
    /// Every emission carries the last known good `data`: a `.loading` (refresh in flight)
    /// or `.error` (refresh failed) state re-attaches the previously emitted data rather than
    /// blanking it. Consumers can therefore assign each emission verbatim and never need to
    /// preserve prior data across `.loading`/`.error` themselves.
    func transactionsStream(filter: TransactionFilter) async -> AsyncStream<DataState<Transaction>>
    func addTransactions(_ newTransactions: [Transaction]) async throws
}

extension TransactionsProviderProtocol {
    func fetchTransactions() async throws -> [Transaction] {
        try await fetchTransactions(filter: TransactionFilter())
    }
}
