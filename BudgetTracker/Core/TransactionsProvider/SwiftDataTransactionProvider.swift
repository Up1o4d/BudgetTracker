import Foundation
import SwiftData

actor SwiftDataTransactionsProvider: TransactionsProviderProtocol {
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = .init(modelContainer)

    private struct Subscription {
        var filter: TransactionFilter
        let continuation: AsyncStream<DataState<Transaction>>.Continuation
        var lastData: [Transaction]
        var generation: Int
    }

    private var streamRegistry: [UUID: Subscription] = [:]

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

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

    func fetchTransactions(uuid: UUID, filter: TransactionFilter) async -> Result<[Transaction], Error> {
        // Retain the filter for this uuid so write-driven re-emits stay correctly scoped, and bump
        // the per-uuid generation so a later fetch supersedes this one's yield. Both writes happen
        // synchronously before the query — for the (synchronous) SwiftData fetch there is no
        // suspension point so this is effectively atomic, but it keeps behavior uniform with the
        // in-memory provider where a slow fetch can be superseded mid-flight.
        streamRegistry[uuid]?.filter = filter
        streamRegistry[uuid]?.generation += 1
        let generation = streamRegistry[uuid]?.generation
        let lastData = streamRegistry[uuid]?.lastData ?? []

        let settled = settledDataState(for: filter, lastData: lastData)

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
        for newTransaction in newTransactions {
            modelContext.insert(StoredTransaction(transaction: newTransaction))
        }

        try modelContext.save()

        // The provider is the sole writer, so poking every registered stream here after a
        // save is what keeps ActivityView's observation live. Future delete/edit paths must
        // also go through the provider and poke the registry, or streams go stale. Each stream
        // is re-run against its own stored filter so re-emits stay per-stream scoped.
        for id in streamRegistry.keys {
            guard let subscription = streamRegistry[id] else { continue }
            let settled = settledDataState(for: subscription.filter, lastData: subscription.lastData)
            streamRegistry[id]?.lastData = settled.data
            subscription.continuation.yield(settled)
        }
    }

    enum FetchError: Error {
        case unknown
    }

    private func deregister(_ id: UUID) {
        streamRegistry.removeValue(forKey: id)
    }

    // Fetches synchronously, so it always settles directly to .idle/.error — never
    // yields an interim .loading state (see the doc comment on the protocol method). On
    // failure, carries `lastData` forward so an `.error` emission never blanks the list.
    private func settledDataState(for filter: TransactionFilter, lastData: [Transaction]) -> DataState<Transaction> {
        do {
            return DataState(loadingState: .idle, data: try fetchFiltered(filter))
        } catch {
            return DataState(loadingState: .error, data: lastData, error: error)
        }
    }

    private func fetchFiltered(_ filter: TransactionFilter) throws -> [Transaction] {
        let categoryIds = filter.categoryIds.map(Array.init) ?? []
        let filterByCategory = filter.categoryIds != nil
        let startDate = filter.dateRange?.lowerBound ?? .distantPast
        let endDate = filter.dateRange?.upperBound ?? .distantFuture
        let filterByDate = filter.dateRange != nil
        let vendorSubstring = filter.vendorSubstring ?? ""
        let filterByVendor = !(filter.vendorSubstring?.isEmpty ?? true)

        let predicate = #Predicate<StoredTransaction> { tx in
            (!filterByCategory || categoryIds.contains(tx.categoryId)) &&
            (!filterByDate || (tx.date >= startDate && tx.date <= endDate)) &&
            (!filterByVendor || tx.vendor.localizedStandardContains(vendorSubstring))
        }

        let descriptor = FetchDescriptor<StoredTransaction>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        return try modelContext.fetch(descriptor).map { $0.asTransaction }
    }
}
