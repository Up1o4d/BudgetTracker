@testable import BudgetTracker
import Foundation
import SwiftData
import Testing

struct SwiftDataTransactionsProviderTests {
    let modelContainer: ModelContainer
    let sut: SwiftDataTransactionsProvider

    init() throws {
        modelContainer = try ModelContainer(
            for: StoredTransaction.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        sut = SwiftDataTransactionsProvider(modelContainer: modelContainer)
    }

    // MARK: - fetchTransactions()

    @Test
    func fetchTransactions_returnsEmptyWhenStoreIsEmpty() async throws {
        let result = try await sut.fetchTransactions()
        #expect(result.isEmpty)
    }

    @Test
    func fetchTransactions_returnsSortedByDateDescending() async throws {
        let older = Transaction(id: "old", amount: 10, vendor: "Old Shop", categoryId: Category.other.id, date: .distantPast)
        let newer = Transaction(id: "new", amount: 20, vendor: "New Shop", categoryId: Category.other.id, date: .distantFuture)

        try await sut.addTransactions([older, newer])
        let result = try await sut.fetchTransactions()

        #expect(result.count == 2)
        #expect(result[0] == newer)
        #expect(result[1] == older)
    }

    // MARK: - addTransactions(_:)

    @Test
    func addTransactions_persistsTransaction() async throws {
        let transaction = Transaction(
            id: "test-1",
            amount: 42.50,
            vendor: "Whole Foods",
            categoryId: Category.groceries.id,
            date: Date()
        )

        try await sut.addTransactions([transaction])
        let result = try await sut.fetchTransactions()

        #expect(result == [transaction])
    }

    @Test
    func addTransactions_persistsMultipleTransactions() async throws {
        let transactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: Category.groceries.id, date: Date()),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: Category.dining.id, date: Date()),
            Transaction(id: "3", amount: 30, vendor: "C", categoryId: Category.rent.id, date: Date()),
        ]

        try await sut.addTransactions(transactions)
        let result = try await sut.fetchTransactions()

        #expect(result.count == 3)
    }
}
