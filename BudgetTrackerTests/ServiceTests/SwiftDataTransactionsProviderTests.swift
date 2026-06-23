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

    // MARK: - fetchTransactions(filter:) — category

    @Test
    func fetchTransactions_withSingleCategoryFilter_returnsOnlyMatchingTransactions() async throws {
        let grocery = Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: .distantPast)
        let dining = Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: Category.dining.id, date: .distantFuture)
        try await sut.addTransactions([grocery, dining])

        let result = try await sut.fetchTransactions(filter: TransactionFilter(categoryIds: [Category.groceries.id]))

        #expect(result == [grocery])
    }

    @Test
    func fetchTransactions_withMultipleCategoryFilter_returnsAllMatchingTransactions() async throws {
        let grocery = Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: .distantPast)
        let dining = Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: Category.dining.id, date: .now)
        let rent = Transaction(id: "3", amount: 1200, vendor: "City Apt", categoryId: Category.rent.id, date: .distantFuture)
        try await sut.addTransactions([grocery, dining, rent])

        let result = try await sut.fetchTransactions(filter: TransactionFilter(categoryIds: [Category.groceries.id, Category.dining.id]))

        #expect(result == [dining, grocery])
    }

    @Test
    func fetchTransactions_withEmptyCategoryFilter_returnsNoTransactions() async throws {
        let grocery = Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: .now)
        try await sut.addTransactions([grocery])

        let result = try await sut.fetchTransactions(filter: TransactionFilter(categoryIds: []))

        #expect(result.isEmpty)
    }

    @Test
    func fetchTransactions_withNilCategoryFilter_returnsAllTransactions() async throws {
        let grocery = Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: .distantPast)
        let dining = Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: Category.dining.id, date: .distantFuture)
        try await sut.addTransactions([grocery, dining])

        let result = try await sut.fetchTransactions(filter: TransactionFilter(categoryIds: nil))

        #expect(result == [dining, grocery])
    }

    // MARK: - fetchTransactions(filter:) — date range

    @Test
    func fetchTransactions_withDateRangeFilter_returnsOnlyTransactionsInRange() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let jan = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!
        let feb = calendar.date(from: DateComponents(year: 2026, month: 2, day: 15))!
        let mar = calendar.date(from: DateComponents(year: 2026, month: 3, day: 15))!

        try await sut.addTransactions([
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: Category.other.id, date: jan),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: Category.other.id, date: feb),
            Transaction(id: "3", amount: 30, vendor: "C", categoryId: Category.other.id, date: mar),
        ])

        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: 2026, month: 2, day: 28))!
        let result = try await sut.fetchTransactions(filter: TransactionFilter(dateRange: start...end))

        #expect(result.map(\.id) == ["2", "1"])
    }

    // MARK: - fetchTransactions(filter:) — vendor

    @Test
    func fetchTransactions_withVendorFilter_returnsOnlyMatchingTransactions() async throws {
        let wholeFoods = Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: .distantPast)
        let sushiBar = Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: Category.dining.id, date: .distantFuture)
        try await sut.addTransactions([wholeFoods, sushiBar])

        let result = try await sut.fetchTransactions(filter: TransactionFilter(vendorSubstring: "Whole"))

        #expect(result == [wholeFoods])
    }

    @Test
    func fetchTransactions_withVendorFilter_isCaseInsensitive() async throws {
        let wholeFoods = Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: .now)
        try await sut.addTransactions([wholeFoods])

        let result = try await sut.fetchTransactions(filter: TransactionFilter(vendorSubstring: "whole"))

        #expect(result == [wholeFoods])
    }

    @Test
    func fetchTransactions_withNilVendorFilter_returnsAllTransactions() async throws {
        let wholeFoods = Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: .distantPast)
        let sushiBar = Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: Category.dining.id, date: .distantFuture)
        try await sut.addTransactions([wholeFoods, sushiBar])

        let result = try await sut.fetchTransactions(filter: TransactionFilter(vendorSubstring: nil))

        #expect(result == [sushiBar, wholeFoods])
    }

    // MARK: - fetchTransactions(filter:) — combined

    @Test
    func fetchTransactions_withCategoryAndDateFilter_appliesBothConditions() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let jan = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!
        let feb = calendar.date(from: DateComponents(year: 2026, month: 2, day: 15))!

        try await sut.addTransactions([
            Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: jan),
            Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: Category.dining.id, date: jan),
            Transaction(id: "3", amount: 30, vendor: "Trader Joe's", categoryId: Category.groceries.id, date: feb),
        ])

        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: 2026, month: 1, day: 31))!
        let result = try await sut.fetchTransactions(filter: TransactionFilter(
            categoryIds: [Category.groceries.id],
            dateRange: start...end
        ))

        #expect(result.map(\.id) == ["1"])
    }

    @Test
    func fetchTransactions_withCategoryAndVendorFilter_appliesBothConditions() async throws {
        let wholeFoodsGroceries = Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: Category.groceries.id, date: .now)
        let wholeFoodsDining = Transaction(id: "2", amount: 20, vendor: "Whole Foods Cafe", categoryId: Category.dining.id, date: .now)
        let traderJoes = Transaction(id: "3", amount: 30, vendor: "Trader Joe's", categoryId: Category.groceries.id, date: .now)
        try await sut.addTransactions([wholeFoodsGroceries, wholeFoodsDining, traderJoes])

        let result = try await sut.fetchTransactions(filter: TransactionFilter(
            categoryIds: [Category.groceries.id],
            vendorSubstring: "Whole"
        ))

        #expect(result == [wholeFoodsGroceries])
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
