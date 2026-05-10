@testable import BudgetTracker
import Foundation
import Testing

struct ActivityViewModelTests {
    let transactionsProvider: MockTransactionsProvider
    let categoriesProvider: MockCategoriesProvider
    let sut: ActivityViewModel

    init() {
        transactionsProvider = MockTransactionsProvider()
        categoriesProvider = MockCategoriesProvider()
        sut = ActivityViewModel(transactionsProvider: transactionsProvider, categoriesProvider: categoriesProvider)
    }

    // MARK: - Initial state

    @Test
    func initialState() {
        #expect(sut.loadingState == .initial)
        #expect(sut.transactions.isEmpty)
        #expect(sut.categories.isEmpty)
    }

    // MARK: - loadData() happy path

    @Test
    func loadData_setsIdleStateWhenTransactionsNonEmpty() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
        ]
        await sut.loadData()
        #expect(sut.loadingState == .idle)
    }

    @Test
    func loadData_setsEmptyStateWhenNoTransactions() async {
        await sut.loadData()
        #expect(sut.loadingState == .empty)
    }

    @Test
    func loadData_populatesTransactions() async {
        let transactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ]
        transactionsProvider.stubbedTransactions = transactions
        await sut.loadData()
        #expect(sut.transactions == transactions)
    }

    @Test
    func loadData_populatesCategories() async {
        let categories: [BudgetTracker.Category] = [.groceries, .dining]
        categoriesProvider.stubbedCategories = categories
        await sut.loadData()
        #expect(sut.categories == categories)
    }

    @Test
    func loadData_callsProvidersOnce() async {
        await sut.loadData()
        #expect(transactionsProvider.fetchTransactionsCallCount == 1)
        #expect(categoriesProvider.fetchCategoriesCallCount == 1)
    }

    // MARK: - loadData() error path

    @Test
    func loadData_setsErrorStateOnTransactionsFailure() async {
        transactionsProvider.stubbedError = NSError(domain: "test", code: 0)
        await sut.loadData()
        #expect(sut.loadingState == .error)
    }

    @Test
    func loadData_setsErrorStateOnCategoriesFailure() async {
        categoriesProvider.stubbedError = NSError(domain: "test", code: 0)
        await sut.loadData()
        #expect(sut.loadingState == .error)
    }

    // MARK: - transactionsByDate

    @Test
    func transactionsByDate_groupsByCalendarDay() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: today),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: today),
            Transaction(id: "3", amount: 30, vendor: "C", categoryId: "rent", date: yesterday),
        ]
        await sut.loadData()

        #expect(sut.transactionsByDate[today]?.count == 2)
        #expect(sut.transactionsByDate[yesterday]?.count == 1)
    }
}
