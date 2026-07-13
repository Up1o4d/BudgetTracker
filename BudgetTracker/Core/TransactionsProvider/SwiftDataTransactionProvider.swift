import Foundation
import SwiftData

actor SwiftDataTransactionsProvider: TransactionsProviderProtocol {
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = .init(modelContainer)

    private struct Subscription {
        let filter: TransactionFilter
        let continuation: AsyncStream<DataState<Transaction>>.Continuation
        var lastData: [Transaction]
    }

    private var streamRegistry: [UUID: Subscription] = [:]

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchTransactions(filter: TransactionFilter) async throws -> [Transaction] {
        try fetchFiltered(filter)
    }

    func transactionsStream(filter: TransactionFilter) async -> AsyncStream<DataState<Transaction>> {
        let (stream, continuation) = AsyncStream.makeStream(of: DataState<Transaction>.self)
        let id = UUID()

        continuation.onTermination = { _ in
            Task { await self.deregister(id) }
        }

        let settled = settledDataState(for: filter, lastData: [])
        streamRegistry[id] = Subscription(filter: filter, continuation: continuation, lastData: settled.data)
        continuation.yield(settled)

        return stream
    }

    func addTransactions(_ newTransactions: [Transaction]) async throws {
        for newTransaction in newTransactions {
            modelContext.insert(StoredTransaction(transaction: newTransaction))
        }

        try modelContext.save()

        // The provider is the sole writer, so poking every registered stream here after a
        // save is what keeps ActivityView's observation live. Future delete/edit paths must
        // also go through the provider and poke the registry, or streams go stale.
        for id in streamRegistry.keys {
            guard let subscription = streamRegistry[id] else { continue }
            let settled = settledDataState(for: subscription.filter, lastData: subscription.lastData)
            streamRegistry[id]?.lastData = settled.data
            subscription.continuation.yield(settled)
        }
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
