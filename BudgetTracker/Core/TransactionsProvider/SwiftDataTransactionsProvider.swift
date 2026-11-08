import Foundation
import SwiftData

actor SwiftDataTransactionsProvider: TransactionsProviderProtocol {
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = .init(modelContainer)

    private let registry = DataStreamRegistry<Transaction>()

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func transactionsStream() async -> (AsyncStream<DataState<Transaction>>, UUID) {
        await registry.makeStream()
    }

    @discardableResult
    func fetchTransactions(uuid: UUID, filter: TransactionFilter) async -> Result<[Transaction], Error> {
        let settled = await registry.fetch(uuid: uuid) { [weak self] in
            guard let self else { throw ProviderError.unknown }
            return try await self.fetchFiltered(filter)
        }

        return settled.loadingState == .error
            ? .failure(settled.error ?? ProviderError.unknown)
            : .success(settled.data)
    }

    func addTransactions(_ newTransactions: [Transaction]) async throws {
        for newTransaction in newTransactions {
            modelContext.insert(StoredTransaction(transaction: newTransaction))
        }

        try modelContext.save()

        // The provider is the sole writer, so re-emitting every registered stream here after a
        // save is what keeps ActivityView's observation live. Future delete/edit paths must
        // also go through the provider and poke the registry, or streams go stale.
        await registry.refetchAll()
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
