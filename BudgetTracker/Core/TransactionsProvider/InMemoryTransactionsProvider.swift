import Foundation

actor InMemoryTransactionsProvider: TransactionsProviderProtocol {
    private nonisolated static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day))!
    }

    private nonisolated static let seed: [Transaction] = [
        Transaction(id: "1", amount: 1200.00, vendor: "City Apartments", categoryId: Category.rent.id, date: date(2026, 1, 1)),
        Transaction(id: "2", amount: 54.30, vendor: "Whole Foods", categoryId: Category.groceries.id, date: date(2026, 1, 3)),
        Transaction(id: "3", amount: 12.50, vendor: "Uber", categoryId: Category.transport.id, date: date(2026, 1, 5)),
        Transaction(id: "4", amount: 38.75, vendor: "The Italian Place", categoryId: Category.dining.id, date: date(2026, 1, 7)),
        Transaction(id: "5", amount: 89.99, vendor: "Electric Company", categoryId: Category.utilities.id, date: date(2026, 1, 9)),
        Transaction(id: "6", amount: 23.10, vendor: "Trader Joe's", categoryId: Category.groceries.id, date: date(2026, 1, 12)),
        Transaction(id: "7", amount: 4.50, vendor: "City Bus Pass", categoryId: Category.transport.id, date: date(2026, 1, 14)),
        Transaction(id: "8", amount: 62.00, vendor: "Sushi Bar", categoryId: Category.dining.id, date: date(2026, 1, 18)),
        Transaction(id: "9", amount: 45.00, vendor: "Internet Provider", categoryId: Category.utilities.id, date: date(2026, 1, 22)),
        Transaction(id: "10", amount: 15.99, vendor: "Amazon", categoryId: Category.other.id, date: date(2026, 1, 25)),
        Transaction(id: "11", amount: 1200.00, vendor: "City Apartments", categoryId: Category.rent.id, date: date(2026, 2, 1)),
        Transaction(id: "12", amount: 67.40, vendor: "Whole Foods", categoryId: Category.groceries.id, date: date(2026, 2, 2)),
        Transaction(id: "13", amount: 9.80, vendor: "Metro Card", categoryId: Category.transport.id, date: date(2026, 2, 4)),
        Transaction(id: "14", amount: 44.00, vendor: "Burger Joint", categoryId: Category.dining.id, date: date(2026, 2, 6)),
        Transaction(id: "15", amount: 92.50, vendor: "Gas & Power Co.", categoryId: Category.utilities.id, date: date(2026, 2, 8)),
        Transaction(id: "16", amount: 31.20, vendor: "Costco", categoryId: Category.groceries.id, date: date(2026, 2, 11)),
        Transaction(id: "17", amount: 18.00, vendor: "Lyft", categoryId: Category.transport.id, date: date(2026, 2, 13)),
        Transaction(id: "18", amount: 75.50, vendor: "Thai Garden", categoryId: Category.dining.id, date: date(2026, 2, 15)),
        Transaction(id: "19", amount: 39.99, vendor: "Spotify", categoryId: Category.other.id, date: date(2026, 2, 17)),
        Transaction(id: "20", amount: 110.00, vendor: "Water Utility", categoryId: Category.utilities.id, date: date(2026, 2, 20)),
        Transaction(id: "21", amount: 1200.00, vendor: "City Apartments", categoryId: Category.rent.id, date: date(2026, 3, 1)),
        Transaction(id: "22", amount: 48.60, vendor: "Trader Joe's", categoryId: Category.groceries.id, date: date(2026, 3, 3)),
        Transaction(id: "23", amount: 22.00, vendor: "Uber", categoryId: Category.transport.id, date: date(2026, 3, 5)),
        Transaction(id: "24", amount: 55.00, vendor: "Pizza Palace", categoryId: Category.dining.id, date: date(2026, 3, 7)),
        Transaction(id: "25", amount: 84.00, vendor: "Electric Company", categoryId: Category.utilities.id, date: date(2026, 3, 10)),
        Transaction(id: "26", amount: 29.75, vendor: "Whole Foods", categoryId: Category.groceries.id, date: date(2026, 3, 13)),
        Transaction(id: "27", amount: 6.00, vendor: "City Bus Pass", categoryId: Category.transport.id, date: date(2026, 3, 15)),
        Transaction(id: "28", amount: 88.00, vendor: "Steakhouse", categoryId: Category.dining.id, date: date(2026, 3, 18)),
        Transaction(id: "29", amount: 14.99, vendor: "Netflix", categoryId: Category.other.id, date: date(2026, 3, 20)),
        Transaction(id: "30", amount: 47.00, vendor: "Internet Provider", categoryId: Category.utilities.id, date: date(2026, 3, 23)),
        Transaction(id: "31", amount: 1200.00, vendor: "City Apartments", categoryId: Category.rent.id, date: date(2026, 4, 1)),
        Transaction(id: "32", amount: 71.30, vendor: "Costco", categoryId: Category.groceries.id, date: date(2026, 4, 3)),
        Transaction(id: "33", amount: 13.50, vendor: "Lyft", categoryId: Category.transport.id, date: date(2026, 4, 5)),
        Transaction(id: "34", amount: 42.00, vendor: "Ramen House", categoryId: Category.dining.id, date: date(2026, 4, 8)),
        Transaction(id: "35", amount: 95.00, vendor: "Gas & Power Co.", categoryId: Category.utilities.id, date: date(2026, 4, 10)),
        Transaction(id: "36", amount: 36.90, vendor: "Trader Joe's", categoryId: Category.groceries.id, date: date(2026, 4, 13)),
        Transaction(id: "37", amount: 8.00, vendor: "Metro Card", categoryId: Category.transport.id, date: date(2026, 4, 15)),
        Transaction(id: "38", amount: 59.00, vendor: "Taco Spot", categoryId: Category.dining.id, date: date(2026, 4, 17)),
        Transaction(id: "39", amount: 24.99, vendor: "Apple iCloud", categoryId: Category.other.id, date: date(2026, 4, 19)),
        Transaction(id: "40", amount: 43.00, vendor: "Water Utility", categoryId: Category.utilities.id, date: date(2026, 4, 21)),
        Transaction(id: "41", amount: 1200.00, vendor: "City Apartments", categoryId: Category.rent.id, date: date(2026, 5, 1)),
        Transaction(id: "42", amount: 52.40, vendor: "Whole Foods", categoryId: Category.groceries.id, date: date(2026, 5, 2)),
        Transaction(id: "43", amount: 11.00, vendor: "Uber", categoryId: Category.transport.id, date: date(2026, 5, 2)),
        Transaction(id: "44", amount: 33.50, vendor: "The Italian Place", categoryId: Category.dining.id, date: date(2026, 5, 3)),
        Transaction(id: "45", amount: 78.00, vendor: "Electric Company", categoryId: Category.utilities.id, date: date(2026, 5, 3)),
        Transaction(id: "46", amount: 19.90, vendor: "Amazon", categoryId: Category.other.id, date: date(2026, 5, 3)),
        Transaction(id: "47", amount: 27.60, vendor: "Trader Joe's", categoryId: Category.groceries.id, date: date(2026, 5, 3)),
        Transaction(id: "48", amount: 5.50, vendor: "City Bus Pass", categoryId: Category.transport.id, date: date(2026, 5, 3)),
        Transaction(id: "49", amount: 66.00, vendor: "Sushi Bar", categoryId: Category.dining.id, date: date(2026, 5, 3)),
        Transaction(id: "50", amount: 49.99, vendor: "Internet Provider", categoryId: Category.utilities.id, date: date(2026, 5, 3)),
    ]

    private struct Subscription {
        var filter: TransactionFilter
        let continuation: AsyncStream<DataState<Transaction>>.Continuation
        var lastData: [Transaction]
        var generation: Int
    }

    private var transactions: [Transaction] = InMemoryTransactionsProvider.seed
    private var streamRegistry: [UUID: Subscription] = [:]

    func transactionsStream() async -> (AsyncStream<DataState<Transaction>>, UUID) {
        let (stream, continuation) = AsyncStream.makeStream(of: DataState<Transaction>.self)
        let id = UUID()

        continuation.onTermination = { _ in
            Task { await self.deregister(id) }
        }

        // Silent channel: registered with an all-nil filter and no emission. The first
        // fetchTransactions(uuid:filter:) sets the filter and pushes the first content.
        streamRegistry[id] = Subscription(filter: TransactionFilter(), continuation: continuation, lastData: [], generation: 0)

        return (stream, id)
    }

    @discardableResult
    func fetchTransactions(uuid: UUID, filter: TransactionFilter) async -> Result<[Transaction], Error> {
        // Retain the filter for this uuid so write-driven re-emits stay correctly scoped, and bump
        // the per-uuid generation so a later fetch supersedes this one's yield. Both writes happen
        // synchronously in this prologue — before the simulated-latency query below suspends — so a
        // second fetch that starts mid-flight has already claimed a newer generation by the time
        // this (now stale) fetch resumes, and its yield is skipped.
        streamRegistry[uuid]?.filter = filter
        streamRegistry[uuid]?.generation += 1
        let generation = streamRegistry[uuid]?.generation
        let lastData = streamRegistry[uuid]?.lastData ?? []

        // The fetch below has a simulated network delay, so signal .loading immediately (carrying
        // the last-known data so the consumer never blanks the list) before yielding the settled
        // result once it lands. Emitted from the prologue, where this fetch is by definition the
        // latest for uuid, so it needs no generation gate — the settled yield below does.
        streamRegistry[uuid]?.continuation.yield(DataState(loadingState: .loading, data: lastData))

        let settled = await settledDataState(for: filter, lastData: lastData)

        // Only yield if this is still the latest fetch for uuid and the stream is live.
        if let subscription = streamRegistry[uuid], subscription.generation == generation {
            streamRegistry[uuid]?.lastData = settled.data
            subscription.continuation.yield(settled)
        }

        return settled.loadingState == .error
            ? .failure(settled.error ?? FetchError.unknown)
            : .success(settled.data)
    }

    func addTransactions(_ newTransactions: [Transaction]) async throws {
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
        transactions.append(contentsOf: newTransactions)

        // The provider is the sole writer, so poking every registered stream here after
        // appending is what keeps ActivityView's observation live. Future delete/edit paths
        // must also go through the provider and poke the registry, or streams go stale.
        //
        // The refetch below goes through fetchTransactions, which has its own simulated
        // network delay — so signal .loading immediately (carrying the last-known data so
        // consumers never blank the list) before yielding the settled result once it lands.
        for id in streamRegistry.keys {
            guard let subscription = streamRegistry[id] else { continue }
            subscription.continuation.yield(DataState(loadingState: .loading, data: subscription.lastData))

            let settled = await settledDataState(for: subscription.filter, lastData: subscription.lastData)
            streamRegistry[id]?.lastData = settled.data
            streamRegistry[id]?.continuation.yield(settled)
        }
    }

    private func deregister(_ id: UUID) {
        streamRegistry.removeValue(forKey: id)
    }

    /// Routed through `fetchFiltered` so every read this provider reports carries the same
    /// simulated network delay a real REST provider's refetch would have. On failure, carries
    /// `lastData` forward so an `.error` emission never blanks a previously-loaded list.
    private func settledDataState(for filter: TransactionFilter, lastData: [Transaction]) async -> DataState<Transaction> {
        do {
            return try DataState(loadingState: .idle, data: await fetchFiltered(filter))
        } catch {
            return DataState(loadingState: .error, data: lastData, error: error)
        }
    }

    /// Simulates a slow network read: the `Task.sleep` is the suspension point that makes the
    /// per-uuid generation supersede in `fetchTransactions` observable — a second fetch can start
    /// (and bump the generation) while an earlier one is parked here.
    private func fetchFiltered(_ filter: TransactionFilter) async throws -> [Transaction] {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.5 ... 1.5)))
        return transactions.filter { filter.matches($0) }
    }

    enum FetchError: Error {
        case unknown
    }
}
