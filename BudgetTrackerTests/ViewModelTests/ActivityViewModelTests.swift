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
        sut = ActivityViewModel(transactionsProvider: transactionsProvider, categoriesProvider: categoriesProvider, appSettings: InMemoryAppSettings())
    }

    // MARK: - Initial state

    @Test
    func initialState() {
        #expect(sut.viewLoadingState == .loading)
        #expect(sut.transactionsState.data.isEmpty)
        #expect(sut.categoriesState.data.isEmpty)
    }

    // MARK: - loadData() happy path

    @Test
    func loadData_setsIdleStateWhenTransactionsNonEmpty() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
        ]
        await sut.loadData()
        #expect(sut.viewLoadingState == .idle)
    }

    @Test
    func loadData_setsIdleStateWhenNoTransactions() async {
        await sut.loadData()
        #expect(sut.viewLoadingState == .idle)
    }

    @Test
    func loadData_populatesTransactions() async {
        let transactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ]
        transactionsProvider.stubbedTransactions = transactions
        await sut.loadData()
        #expect(sut.transactionsState.data == transactions)
    }

    @Test
    func loadData_populatesCategories() async {
        let categories: [BudgetTracker.Category] = [.groceries, .dining]
        categoriesProvider.stubbedCategories = categories
        await sut.loadData()
        #expect(sut.categoriesState.data == categories)
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
        #expect(sut.viewLoadingState == .error)
    }

    @Test
    func loadData_setsErrorStateOnCategoriesFailure() async {
        categoriesProvider.stubbedError = NSError(domain: "test", code: 0)
        await sut.loadData()
        #expect(sut.viewLoadingState == .error)
    }

    // MARK: - toggleFilterCategory

    @Test
    func toggleFilterCategory_addsCategory() {
        sut.toggleFilterCategory(.groceries)
        #expect(sut.filterCategoryIds == ["groceries"])
    }

    @Test
    func toggleFilterCategory_removesOnSecondToggle() {
        sut.toggleFilterCategory(.groceries)
        sut.toggleFilterCategory(.groceries)
        #expect(sut.filterCategoryIds.isEmpty)
    }

    @Test
    func toggleFilterCategory_categoriesAreIndependent() {
        sut.toggleFilterCategory(.groceries)
        sut.toggleFilterCategory(.dining)
        sut.toggleFilterCategory(.groceries)
        #expect(sut.filterCategoryIds == ["dining"])
    }

    @Test
    func toggleFilterCategory_reloadsTransactionsWithFilter() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ]
        await sut.loadData()
        await sut.toggleFilterCategory(.groceries).value
        #expect(sut.transactionsState.data.count == 1)
        #expect(sut.transactionsState.data.first?.categoryId == "groceries")
    }

    // MARK: - resetFilterCategories

    @Test
    func resetFilterCategories_clearsAllFilters() {
        sut.toggleFilterCategory(.groceries)
        sut.toggleFilterCategory(.dining)
        sut.resetFilterCategories()
        #expect(sut.filterCategoryIds.isEmpty)
    }

    @Test
    func resetFilterCategories_reloadsAllTransactions() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ]
        await sut.loadData()
        await sut.toggleFilterCategory(.groceries).value
        await sut.resetFilterCategories().value
        #expect(sut.transactionsState.data.count == 2)
    }

    // MARK: - searchString

    @Test
    func searchString_reloadsTransactionsFilteredByVendor() async throws {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: "dining", date: .now),
        ]
        await sut.loadData()

        sut.searchString = "Whole"
        try await Task.sleep(for: .milliseconds(400))

        #expect(sut.transactionsState.data.count == 1)
        #expect(sut.transactionsState.data.first?.vendor == "Whole Foods")
    }

    @Test
    func searchString_emptyString_returnsAllTransactions() async throws {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: "dining", date: .now),
        ]
        await sut.loadData()

        sut.searchString = "Whole"
        try await Task.sleep(for: .milliseconds(400))
        sut.searchString = ""
        try await Task.sleep(for: .milliseconds(400))

        #expect(sut.transactionsState.data.count == 2)
    }

    // MARK: - transactionCategoriesByDate

    @Test
    func transactionCategoriesByDate_groupsByCalendarDay() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: today),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: today),
            Transaction(id: "3", amount: 30, vendor: "C", categoryId: "rent", date: yesterday),
        ]
        await sut.loadData()

        #expect(sut.transactionCategoriesByDate[today]?.count == 2)
        #expect(sut.transactionCategoriesByDate[yesterday]?.count == 1)
    }
}
