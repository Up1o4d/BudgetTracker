import Foundation
import SwiftData

actor SwiftDataTransactionsProvider: TransactionsProviderProtocol {
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = .init(modelContainer)

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchTransactions(filter: TransactionFilter) async throws -> [Transaction] {
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

    func addTransactions(_ newTransactions: [Transaction]) async throws {
        for newTransaction in newTransactions {
            modelContext.insert(StoredTransaction(transaction: newTransaction))
        }

        try modelContext.save()
    }
}
