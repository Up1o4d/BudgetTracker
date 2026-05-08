import Foundation
import SwiftData

final class SwiftDataTransactionsProvider: TransactionsProviderProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        modelContext = modelContainer.mainContext
    }

    func fetchTransactions() async throws -> [Transaction] {
        let descriptor = FetchDescriptor<StoredTransaction>(
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
